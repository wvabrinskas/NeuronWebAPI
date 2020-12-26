//
//  CameraCoordinator.swift
//  NeuroCam
//
//  Created by William Vabrinskas on 12/11/20.
//

import Foundation
import Neuron

public class NeuroCoordinator: ObservableObject {
  @Published public var result: [Float] = []
  
  public var outputs: Int
  public var inputs: Int
  private var brain: Brain
  
  private static func getActivation(_ mode: ActivationMode) -> Activation {
    switch mode {
    case .reLu:
      return .reLu
    case .leakyReLu:
      return .leakyRelu
    case .sigmoid:
      return .sigmoid
    case .swish:
      return .swish
    }
  }
  
  private static func getLossFunction(_ mode: LossFunctionMode) -> LossFunction {
    switch mode {
    case .meanSquareLoss:
      return .meanSquareError
    }
  }
  
  init(inputs: Int,
       outputs: Int,
       hiddenLayers: Int = 0,
       learningRate: Float = 0.01,
       bias: Float = 0.01,
       activation: ActivationMode = .reLu,
       lossFunction: LossFunctionMode = .meanSquareLoss,
       lossThreshold: Float = 0.001) {
    
    self.inputs = inputs
    self.outputs = outputs
    
    let nucleus = Nucleus(learningRate: learningRate,
                          bias: bias,
                          activationType: Self.getActivation(activation))
    
    let brain = Brain(inputs: inputs,
                      outputs: outputs,
                      hidden: (inputs + outputs) / 2,
                      hiddenLayers: hiddenLayers,
                      nucleus: nucleus,
                      lossFunction: Self.getLossFunction(lossFunction),
                      lossThreshold: lossThreshold)
    self.brain = brain
  }
  
  public func get(inputs: [Float], complete: ((_ result: [Float]) -> ())? = nil) {
    self.result = self.brain.feed(input: inputs)
    complete?(self.result)
  }
  
  public func train(inputs: [Float], correct: [Float], complete: ((_ finished: Bool) -> ())? = nil) {
    self.brain.train(data: inputs, correct: correct, complete: complete)
  }

}

