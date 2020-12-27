//
//  File.swift
//  
//
//  Created by William Vabrinskas on 12/27/20.
//

import Foundation
import Vapor

public struct WebResponseModel<T: Codable>: Codable, ResponseEncodable {
  public var status: Bool
  public var error: RequestCoordinator.RequestError? = nil
  public var result: T?

  public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
    let responseHeaders: HTTPHeaders = ["content-type": "application/json; charset=utf-8"]

    let body = Response.Body(staticString: "fatal error =(")
    var res = Response(headers: responseHeaders, body: body)
    
    do {
      let data = try JSONEncoder().encode(self.self)
      res = Response(headers: responseHeaders, body: .init(data: data))
      
    } catch {
      let errorData: [String: Any?] =
        [
          "status": false,
          "error": "Could not decode response model",
          "result": nil
        ]
      
      if let data = try? JSONSerialization.data(withJSONObject: errorData, options: .fragmentsAllowed) {
        res = Response(headers: responseHeaders, body: .init(data: data))
      }
    }
  
    return request.eventLoop.makeSucceededFuture(res)
  }
  
}
