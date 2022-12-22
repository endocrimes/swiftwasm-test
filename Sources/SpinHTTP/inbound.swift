//
//  File.swift
//  
//
//  Created by Danielle Lancashire on 09/12/2022.
//

import Foundation
import CSpinHTTP

public enum HTTPMethod: UInt8 {
    case GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS
    
    private var allMethods: [HTTPMethod] {
        [.GET, .POST, .PUT, .DELETE, .PATCH, .HEAD, .OPTIONS]
    }
}

public struct HTTPRequest {
    public let URI: String
    public let Method: HTTPMethod
    public let Headers: [String: String]
    public let Host: String?
    public let Body: Data?
    
    public init(URI: String, Method: HTTPMethod, Headers: [String : String], Host: String?, Body: Data?) {
        self.URI = URI
        self.Method = Method
        self.Headers = Headers
        self.Host = Host
        self.Body = Body
    }
}

public struct HTTPResponse {
    public var StatusCode: Int
    public var Headers: [String: String]
    public var Body: Data?
    
    public init(statusCode: Int, headers: [String : String] = [:], body: Data?) {
        self.StatusCode = statusCode
        self.Headers = headers
        self.Body = body
    }
    
    public init(statusCode: Int, headers: [String : String] = [:], body: String?) {
        self.StatusCode = statusCode
        self.Headers = headers
        self.Body = body?.data(using: .utf8)
    }
    
    public init(statusCode: Int, headers: [String : String] = [:], JSON: Codable) throws {
        self.StatusCode = statusCode
        self.Headers = headers
        self.Headers["content-type"] = "application/json"
        let jsonEncoder = JSONEncoder()
        self.Body = try jsonEncoder.encode(JSON)
    }
}

public typealias HandlerFunc = (HTTPRequest) -> HTTPResponse

extension spin_http_string_t {
    func ToSwiftString() -> String {
        return String(cString: ptr, encoding: .utf8) ?? ""
    }
    
    init(fromSwiftString swiftStr: String) {
        let cStr = swiftStr.cString(using: .utf8)!
        let ptr = UnsafeMutablePointer<CChar>.allocate(capacity: cStr.count)
        ptr.initialize(from: cStr, count: cStr.count)
        // Exclude the null terminator so spin reads things properly.
        self.init(ptr: ptr, len: cStr.count - 1)
    }
}

public typealias SpinRawRequest = UnsafeMutablePointer<spin_http_request_t>
public typealias SpinRawResponse = UnsafeMutablePointer<spin_http_response_t>

func fromSpinHeaders(headers: spin_http_headers_t) -> [String: String] {
    let headersBuffer = UnsafeBufferPointer(start: headers.ptr, count: headers.len)
    return [spin_http_tuple2_string_string_t].init(headersBuffer).reduce(into: [String: String]()) { accu, tuple in
        let key = tuple.f0.ToSwiftString()
        let value = tuple.f1.ToSwiftString()
        accu[key] = value
    }
}

func toSpinHeaders(headers: [String: String]) -> spin_http_option_headers_t {
    let headerTuples = headers.map({ key, value in
        spin_http_tuple2_string_string_t(
            f0: spin_http_string_t(fromSwiftString: key),
            f1: spin_http_string_t(fromSwiftString: value)
        )
    })
    
    let tuplePointer = UnsafeMutablePointer<spin_http_tuple2_string_string_t>.allocate(capacity: headerTuples.count)
    tuplePointer.initialize(from: headerTuples, count: headerTuples.count)
    let result = spin_http_headers_t(
        ptr: tuplePointer,
        len: headerTuples.count
    )

    return spin_http_option_headers_t(
        is_some: !headerTuples.isEmpty,
        val: result
    )
}

public var spinHandler: HandlerFunc = { req in
    return HTTPResponse(
        statusCode: 200,
        headers: [
            "content-type": "text/html; charset=utf-8",
        ],
        body: "<html><h1>Hello</h1><br />Welcome to Spin!<br />The source code is available <a href=\"https://github.com/endocrimes/swiftwasm-test\">here</a></html>\n"
    )
}

@_cdecl("spin_http_handle_http_request")
public func handleSpinHTTPRequest(_ reqPtr: SpinRawRequest, _ resPtr: SpinRawResponse)  {
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
    let headers = fromSpinHeaders(headers: request.headers)
    let host = headers["Host"]
    
    let rr = HTTPRequest(
        URI: uri,
        Method: method!,
        Headers: headers,
        Host: host,
        Body: body
    )
    
    let rs = spinHandler(rr)

    resPtr.pointee.status = UInt16(rs.StatusCode)
    let responseHeaders = toSpinHeaders(headers: rs.Headers)
    resPtr.pointee.headers = responseHeaders
    if let resBody = rs.Body {
        resPtr.pointee.body.is_some = true
        let bodyPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: resBody.count)
        bodyPtr.initialize(from: [UInt8](resBody), count: resBody.count)
        resPtr.pointee.body.val = spin_http_body_t(
            ptr: bodyPtr,
            len: resBody.count
        )
    }
}
