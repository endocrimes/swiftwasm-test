import Foundation
import RoutingKit

public struct HTTPRequest {
  public let URI: String
  public let method: HTTPMethod
  public let headers: [String: String]
  public var params: Parameters

  public let host: String?
  public let body: Data?

  public init(
    uRI: String, method: HTTPMethod, headers: [String: String], host: String?, body: Data?
  ) {
    self.URI = uRI
    self.method = method
    self.headers = headers
    self.host = host
    self.body = body
    self.params = .init()
  }
}

public enum HTTPMethod: UInt8 {
  case get, post, put, delete, patch, head, options

  private var allMethods: [HTTPMethod] {
    [.get, .post, .put, .delete, .patch, .head, .options]
  }

  internal var stringValue: String {
    switch self {
    case .get:
      return "GET"
    case .post:
      return "POST"
    case .put:
      return "PUT"
    case .delete:
      return "DELETE"
    case .patch:
      return "PATCH"
    case .head:
      return "HEAD"
    case .options:
      return "OPTIONS"
    }
  }
}

public struct HTTPResponse {
  public var statusCode: Int
  public var headers: [String: String]
  public var body: Data?

  public init(statusCode: Int, headers: [String: String] = [:], body: Data?) {
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
  }

  public init(statusCode: Int, headers: [String: String] = [:], body: String?) {
    self.statusCode = statusCode
    self.headers = headers
    self.body = body?.data(using: .utf8)
  }

  public init(statusCode: Int, headers: [String: String] = [:], JSON: Codable) throws {
    self.statusCode = statusCode
    self.headers = headers
    self.headers["content-type"] = "application/json"
    let jsonEncoder = JSONEncoder()
    self.body = try jsonEncoder.encode(JSON)
  }
}
