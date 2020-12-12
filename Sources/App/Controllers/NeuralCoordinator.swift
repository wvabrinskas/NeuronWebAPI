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
  
  init(inputs: Int,
       outputs: Int,
       hiddenLayers: Int = 0,
       learningRate: Float = 0.01,
       bias: Float = 0.01) {
    
    self.inputs = inputs
    self.outputs = outputs
    
    let nucleus = Nucleus(learningRate: learningRate, bias: bias, activationType: .reLu)
    let brain = Brain(inputs: inputs,
                      outputs: outputs,
                      hidden: (inputs + outputs) / 2,
                      hiddenLayers: hiddenLayers,
                      nucleus: nucleus)
    self.brain = brain
  }
  
  public func get(inputs: [Float], complete: ((_ result: [Float]) -> ())? = nil) {
    self.result = self.brain.feed(input: inputs)
    complete?(self.result)
  }
  
  public func train(inputs: [Float], correct: [Float]) {
    self.brain.train(data: inputs, correct: correct)
  }
}

