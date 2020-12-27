import Vapor
import NeuronWebAPISDK

extension ResponseModel: ResponseEncodable {
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


public let requestCoordinator = RequestCoordinator()

func routes(_ app: Application) throws {
  app.get { req in
    return req.view.render("index", ["title": "Swift Neural Network!"])
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  app.post("init") { req -> EventLoopFuture<WebResponseModel<String?>> in
    return requestCoordinator.initialize(req)
  }
  
  app.on(.POST,"train", body: .collect(maxSize: "5mb")) { req -> WebResponseModel<String?> in
    return requestCoordinator.train(req)
  }

  app.on(.POST, "get", body: .collect(maxSize: "5mb")) { (req) -> EventLoopFuture<WebResponseModel<[Float]>> in
    return requestCoordinator.get(req)
  }
}


