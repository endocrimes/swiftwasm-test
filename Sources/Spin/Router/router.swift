import Foundation
import RoutingKit

public final class Router {
  public typealias Handler = (HTTPRequest) throws -> HTTPResponse

  public let prefix: String

  private var middleware: [Handler] = []

  private let router: TrieRouter<Handler>

  public init(prefix path: String = "/") {
    self.prefix = path
    self.router = TrieRouter()
  }

  @discardableResult
  private func add(method: HTTPMethod, path: String, handler: @escaping Handler) -> Self {
    let pathComponents = path.components(separatedBy: "/").filter { $0.isEmpty == false }
    let prefixComponents = prefix.components(separatedBy: "/").filter { $0.isEmpty == false }
    let combinedComponents = [method.stringValue] + prefixComponents + pathComponents
    print(combinedComponents)
    router.register(handler, at: combinedComponents.map { .init(stringLiteral: $0) })
    return self
  }

  private func handler(for req: inout HTTPRequest) -> Handler? {
    let pathComponents = req.URI.pathComponents.dropFirst()
    return router.route(
      path: [req.method.stringValue] + pathComponents.stringArray,
      parameters: &req.params)
  }
}

extension Router {
  @discardableResult
  public func get(_ path: String, _ handler: @escaping Handler) -> Self {
    add(method: .head, path: path, handler: handler)
    return add(method: .get, path: path, handler: handler)
  }

  @discardableResult
  public func post(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .post, path: path, handler: handler)
  }

  @discardableResult
  public func put(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .put, path: path, handler: handler)
  }

  @discardableResult
  public func delete(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .delete, path: path, handler: handler)
  }

  @discardableResult
  public func options(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .options, path: path, handler: handler)
  }

  @discardableResult
  public func patch(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .patch, path: path, handler: handler)
  }

  @discardableResult
  public func head(_ path: String, _ handler: @escaping Handler) -> Self {
    return add(method: .head, path: path, handler: handler)
  }
}

extension Router {
  @discardableResult
  public func use(_ handler: @escaping Handler) -> Self {
    middleware.append(handler)
    return self
  }
}

extension Router {
  public func run(req: HTTPRequest) -> HTTPResponse {
    do {
      // Create a mutable copy
      var req = req

      // Find matching handler
      guard let handler = handler(for: &req) else {
        return HTTPResponse(statusCode: 404, body: "Not Found: \(req.method) \(req.URI)")
      }

      // Run handler
      return try handler(req)
    } catch {
      return HTTPResponse(statusCode: 500, body: "Internal Server Error")
    }
  }
}
