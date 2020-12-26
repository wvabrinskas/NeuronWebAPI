//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/12/20.
//

import Foundation

struct TrainingModel: Codable {
  var inputs: [Float]
  var validation: [Float]
  var correct: [Float]
}

struct MasterTrainingModel: Codable {
  var trainingData: [TrainingModel]
  var count: Int
}
