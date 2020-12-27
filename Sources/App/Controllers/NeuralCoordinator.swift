//
//  CameraCoordinator.swift
//  NeuroCam
//
//  Created by William Vabrinskas on 12/11/20.
//

import Foundation
import Neuron
import NeuronWebAPISDK

public class NeuroCoordinator: ObservableObject {
  @Published public var result: [Float] = []

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
    case .none:
      return .none
    }
  }
  
  private static func getLossFunction(_ mode: LossFunctionMode) -> LossFunction {
    switch mode {
    case .meanSquareLoss:
      return .meanSquareError
    }
  }
  
  private static func getModifier(_ mode: ModifierMode) -> OutputModifier {
    switch mode {
    case .softmax:
      return .softmax
    }
  }
  
  init(layers: [Layer],
       learningRate: Float = 0.01,
       bias: Float = 0.01,
       epochs: Int,
       defaultActivation: ActivationMode = .reLu,
       lossFunction: LossFunctionMode = .meanSquareLoss,
       lossThreshold: Float = 0.0005,
       modifier: ModifierMode? = nil) {
    
    let nucleus = Nucleus(learningRate: learningRate,
                          bias: bias,
                          activationType: Self.getActivation(defaultActivation))
    
    
    let brain = Brain(nucleus: nucleus,
                      epochs: epochs,
                      lossFunction: Self.getLossFunction(lossFunction),
                      lossThreshold: lossThreshold)
    
    layers.forEach { (layer) in
      brain.add(.layer(layer.nodes, Self.getActivation(layer.activation)))
    }
    
    if let modifier = modifier {
      brain.add(modifier: Self.getModifier(modifier))
    }

    brain.compile()
    
    self.brain = brain
  }
  
  public func get(inputs: [Float], complete: ((_ result: [Float]) -> ())? = nil) {
    self.result = self.brain.feed(input: inputs)
    complete?(self.result)
  }
  
  public func train(inputs: [TrainingModel],
                    validation: [TrainingModel] = [],
                    complete: ((_ finished: Bool) -> ())? = nil) {
    
    let newInputs = inputs.map({ TrainingData(data: $0.inputs, correct: $0.correct) })
    let newValidation = validation.map({ TrainingData(data: $0.inputs, correct: $0.correct) })
    
    self.brain.train(data: newInputs, validation: newValidation, complete: complete)
  }

}

