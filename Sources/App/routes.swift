import Vapor

public let requestCoordinator = RequestCoordinator()

func routes(_ app: Application) throws {
  app.get { req in
    return req.view.render("index", ["title": "Swift Neural Network!"])
  }
  
  app.get("hello") { req -> String in
    return "Hello, world!"
  }
  
  app.post("init") { req -> ResponseModel<String?> in
    return requestCoordinator.initialize(req)
  }
  
  app.post("train") { req -> ResponseModel<String?> in
    return requestCoordinator.train(req)
  }
  
  app.post("get") { (req) -> EventLoopFuture<ResponseModel<[Float]>> in
    return requestCoordinator.get(req)
  }
}


