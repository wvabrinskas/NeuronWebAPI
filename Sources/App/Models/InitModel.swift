//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/12/20.
//

import Foundation

public enum ActivationMode: String, Codable {
  case reLu, sigmoid, leakyReLu, swish
}

public enum LossFunctionMode: String, Codable {
  case meanSquareLoss
}

struct InitModel: Codable {
  var inputs: Int
  var outputs: Int
  var hiddenLayers: Int?
  var learningRate: Float
  var bias: Float
  var activation: ActivationMode
  var lossFunction: LossFunctionMode
  var lossThreshold: Float
}
