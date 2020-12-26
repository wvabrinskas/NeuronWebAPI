import Vapor

public let requestCoordinator = RequestCoordinator()

func routes(_ app: Application) throws {
  app.get { req in
    return req.view.render("index", ["title": "Swift Neural Network!"])
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  app.post("init") { req -> EventLoopFuture<ResponseModel<String?>> in
    return requestCoordinator.initialize(req)
  }
  
  app.on(.POST,"train", body: .collect(maxSize: "1mb")) { req -> ResponseModel<String?> in
    return requestCoordinator.train(req)
  }

  app.on(.POST, "get", body: .collect(maxSize: "1mb")) { (req) -> EventLoopFuture<ResponseModel<[Float]>> in
    return requestCoordinator.get(req)
  }
}


