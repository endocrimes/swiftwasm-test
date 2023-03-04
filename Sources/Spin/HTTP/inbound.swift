import CSpinHTTP
import Foundation

// HandlerFunc is a function that takes a HTTPRequest and returns a HTTPResponse.
public typealias HandlerFunc = (HTTPRequest) -> HTTPResponse

public typealias SpinRawRequest = UnsafeMutablePointer<spin_http_request_t>
public typealias SpinRawResponse = UnsafeMutablePointer<spin_http_response_t>

// spinHandler is the entrypoint for a HTTP Request within the SpinSDK for HTTP Components.
public var spinHandler: HandlerFunc = { req in
  return HTTPResponse(
    statusCode: 200,
    headers: [
      "content-type": "text/html; charset=utf-8"
    ],
    body:
      "<html><h1>Hello</h1><br />Welcome to Spin!<br />The source code is available <a href=\"https://github.com/endocrimes/swiftwasm-test\">here</a></html>\n"
  )
}

@_cdecl("spin_http_handle_http_request")
public func handleSpinHTTPRequest(_ reqPtr: SpinRawRequest, _ response: SpinRawResponse) {
  defer {
    spin_http_request_free(reqPtr)
  }

  let request = reqPtr.pointee

  var body: Data?
  if request.body.is_some {
    body = Data(bytes: request.body.val.ptr, count: request.body.val.len)
  }

  let method = HTTPMethod(rawValue: request.method)

  let uri = String(cString: request.uri.ptr, encoding: .utf8) ?? "unknown"
  let headers = request.headers.dictionaryValue
  let host = headers["Host"]

  let rr = HTTPRequest(
    uRI: uri,
    method: method!,
    headers: headers,
    host: host,
    body: body
  )

  let rs = spinHandler(rr)

  response.pointee.status = rs.spinStatus
  response.pointee.headers = rs.spinHeaders
  if let body = rs.spinBody {
    response.pointee.body.is_some = true
    response.pointee.body.val = body
  } else {
    response.pointee.body.is_some = false
  }
}
