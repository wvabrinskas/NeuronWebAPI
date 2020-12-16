//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/12/20.
//

import Foundation
import Vapor

public class RequestCoordinator {
  private var neuro: NeuroCoordinator?
  
  public enum RequestError: String, Codable {
    case initError = "init not called. Please make a post request to /init with initialize data, or the network isn't ready"
    case feedModelError = "Could not decode feed model with form data"
    case trainingModelError = "Could not decode training model with form data"
    case requestModelError = "Could not decode init model with form data"
    case alreadyInitError = "Neuro coordinator is already initialized."
    case getResultError = "Could not retrieve data from neural network"
  }
  
  public func initialize(_ req: Request) -> ResponseModel<String?> {
    var requestModel: InitModel?
    
    do {
      requestModel = try req.content.decode(InitModel.self)
    } catch {
      print(error)
      return ResponseModel(status: false, error: .requestModelError, result: nil)
    }
    
    if neuro == nil {
      guard let reqModel = requestModel else {
        return ResponseModel(status: false, error: .requestModelError , result: nil)
      }
      
      print("initializing....")
      
      neuro = NeuroCoordinator(inputs: reqModel.inputs,
                               outputs: reqModel.outputs,
                               hiddenLayers: reqModel.hiddenLayers ?? 0,
                               learningRate: reqModel.learningRate,
                               bias: reqModel.bias)
      
      print("initialized.")
      
      return ResponseModel(status: true, result: "successfully init neuro coordinator")
    }
    
    return ResponseModel(status: false, error: .alreadyInitError, result: nil)
  }
  
  public func train(_ req: Request) -> EventLoopFuture<ResponseModel<String?>> {
    
    let promise = req.eventLoop.makePromise(of: ResponseModel<String?>.self)

    guard neuro != nil else {
      let model: ResponseModel<String?> = ResponseModel(status: false,
                                                        error: .initError,
                                                        result: nil)
      promise.succeed(model)
      return promise.futureResult
    }
    

    do {
      let trainingModel = try req.content.decode(MasterTrainingModel.self)
      print("training...")

      for _ in 0..<trainingModel.count {
        let models = trainingModel.trainingData
        for model in models {
          neuro?.train(inputs: model.inputs, correct: model.correct)
        }
      }
      
      print("training complete.")
      
      promise.succeed(ResponseModel(status: true, result: "successfully initialized training...."))
      
    } catch {
      promise.succeed(ResponseModel(status: false, error: .trainingModelError, result: nil))
    }
    
    return promise.futureResult
  }
  
  public func get(_ req: Request) -> EventLoopFuture<ResponseModel<[Float]>> {
    
    let promise = req.eventLoop.makePromise(of: ResponseModel<[Float]>.self)
    
    guard self.neuro != nil else {
      promise.succeed(ResponseModel(status: false,
                           error: .initError,
                           result: nil))
      return promise.futureResult
    }
    
    do {
      let feedModel = try req.content.decode(FeedModel.self)
      
      self.neuro?.get(inputs: feedModel.inputs, complete: { (result) in
        print("got result \(result)")
        promise.succeed(ResponseModel(status: true, result: result))
      })
      
    } catch {
      promise.succeed(ResponseModel(status: false, error: .feedModelError, result: []))
    }
        
    return promise.futureResult
  }

}
