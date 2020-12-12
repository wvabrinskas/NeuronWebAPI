//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/12/20.
//

import Foundation

struct InitModel: Codable {
  var inputs: Int
  var outputs: Int
  var hiddenLayers: Int?
  var learningRate: Float
  var bias: Float
}
