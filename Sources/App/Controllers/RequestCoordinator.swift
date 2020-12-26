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
  
  public func initialize(_ req: Request) -> EventLoopFuture<ResponseModel<String?>> {
    let promise = req.eventLoop.makePromise(of: ResponseModel<String?>.self)

    var requestModel: InitModel?
    
    do {
      requestModel = try req.content.decode(InitModel.self)
    } catch {
      print(error)
      promise.succeed(ResponseModel(status: false, error: .requestModelError, result: nil))
      return promise.futureResult
    }
    
    if neuro == nil {
      guard let reqModel = requestModel else {
        promise.succeed(ResponseModel(status: false, error: .requestModelError , result: nil))
      }
      
      print("initializing....")
      
      neuro = NeuroCoordinator(inputs: reqModel.inputs,
                               outputs: reqModel.outputs,
                               hiddenLayers: reqModel.hiddenLayers ?? 0,
                               learningRate: reqModel.learningRate,
                               bias: reqModel.bias,
                               lossFunction: reqModel.lossFunction,
                               lossThreshold: reqModel.lossThreshold)
      
      print("initialized.")
      
      promise.succeed(ResponseModel(status: true, result: "successfully init neuro coordinator"))
    } else {
      promise.succeed(ResponseModel(status: false, error: .alreadyInitError, result: nil))
    }
    
    return promise.futureResult
  }
  
  public func train(_ req: Request) -> ResponseModel<String?> {
    
    guard neuro != nil else {
      let model: ResponseModel<String?> = ResponseModel(status: false,
                                                        error: .initError,
                                                        result: nil)
      return model
    }
    

    do {
      let trainingModel = try req.content.decode(MasterTrainingModel.self)
      
      DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        print("training...")
        
        var finishedTraining = false
        var i = 0
        
        while i < trainingModel.count && !finishedTraining {
          let models = trainingModel.trainingData
          var j = 0
          print("iteration: \(i)")

          for model in models {
            print("epoch: \(j)")
            self?.neuro?.train(inputs: model.inputs, correct: model.correct, complete: { (finished) in
              finishedTraining = finished
            })
            j += 1
          }
          
          i += 1
        }
        
        print("training complete.")
      }

      return ResponseModel(status: true, result: "successfully initialized training....")
      
    } catch {
      return ResponseModel(status: false, error: .trainingModelError, result: nil)
    }
  
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
