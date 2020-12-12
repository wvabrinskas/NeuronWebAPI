//
//  ModelBuilder.swift
//  Nameley
//
//  Created by William Vabrinskas on 7/10/20.
//  Copyright © 2020 William Vabrinskas. All rights reserved.
//

import Foundation

public protocol ModelBuilder {
  associatedtype T
  var data: T? { get set }
  func build<TViewModel: Decodable>(_ json: [AnyHashable : Any]?) -> TViewModel?
}

extension ModelBuilder {
  @discardableResult
  public func build<TViewModel: Decodable>(_ json: [AnyHashable : Any]?) -> TViewModel? {
      guard let jsonData = json else {
          return nil
      }
      
      do {
          let modelData = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
          let model = try JSONDecoder().decode(TViewModel.self, from: modelData)
          return model
      } catch {
          return nil
      }
  }
}
