//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/12/20.
//

import Foundation
import Vapor
import NeuronWebAPISDK

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
  
  public func initialize(_ req: Request) -> EventLoopFuture<WebResponseModel<String?>> {
    let promise = req.eventLoop.makePromise(of: WebResponseModel<String?>.self)

    var requestModel: InitModel?
    
    do {
      requestModel = try req.content.decode(InitModel.self)
    } catch {
      print(error)
      promise.succeed(WebResponseModel(status: false, error: .requestModelError, result: nil))
      return promise.futureResult
    }
    
    if neuro == nil {
      guard let reqModel = requestModel else {
        promise.succeed(WebResponseModel(status: false, error: .requestModelError , result: nil))
        return promise.futureResult
      }
      
      print("initializing....")
      
      neuro = NeuroCoordinator(layers: reqModel.layers,
                               learningRate: reqModel.learningRate,
                               bias: reqModel.bias,
                               epochs: reqModel.epochs,
                               defaultActivation: .swish,
                               lossFunction: reqModel.lossFunction,
                               lossThreshold: reqModel.lossThreshold,
                               modifier: reqModel.modifier)
      
      
      print("initialized.")
      
      promise.succeed(WebResponseModel(status: true, result: "successfully init neuro coordinator"))
    } else {
      promise.succeed(WebResponseModel(status: false, error: .alreadyInitError, result: nil))
    }
    
    return promise.futureResult
  }
  
  public func train(_ req: Request) -> WebResponseModel<String?> {
    
    guard neuro != nil else {
      let model: WebResponseModel<String?> = WebResponseModel(status: false,
                                                        error: .initError,
                                                        result: nil)
      return model
    }
    

    do {
      let trainingModel = try req.content.decode(MasterTrainingModel.self)
      
      DispatchQueue.global().async {
        self.neuro?.train(inputs: trainingModel.trainingData,
                          validation: trainingModel.validationData, complete: { (complete) in
          print("done training...")
        })

      }

      return WebResponseModel(status: true, result: "successfully initialized training....")
      
    } catch {
      return WebResponseModel(status: false, error: .trainingModelError, result: nil)
    }
  
  }
  
  public func get(_ req: Request) -> EventLoopFuture<WebResponseModel<[Float]>> {
    
    let promise = req.eventLoop.makePromise(of: WebResponseModel<[Float]>.self)
    
    guard self.neuro != nil else {
      promise.succeed(WebResponseModel(status: false,
                           error: .initError,
                           result: nil))
      return promise.futureResult
    }
    
    do {
      let feedModel = try req.content.decode(FeedModel.self)
      
      self.neuro?.get(inputs: feedModel.inputs, complete: { (result) in
        print("got result \(result)")
        promise.succeed(WebResponseModel(status: true, result: result))
      })
      
    } catch {
      promise.succeed(WebResponseModel(status: false, error: .feedModelError, result: []))
    }
        
    return promise.futureResult
  }

}
