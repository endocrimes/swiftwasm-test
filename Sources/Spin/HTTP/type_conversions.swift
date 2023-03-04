import CSpinHTTP
import Foundation

extension HTTPResponse {
  var spinStatus: UInt16 {
    return UInt16(statusCode)
  }

  var spinHeaders: spin_http_option_headers_t {
    return spin_http_option_headers_t(
      is_some: !headers.isEmpty, val: spin_http_headers_t(fromDict: headers))
  }

  var spinBody: spin_http_body_t? {
    if let body = body {
      let len = body.count
      let bodyPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
      bodyPtr.initialize(from: [UInt8](body), count: len)
      return spin_http_body_t(
        ptr: bodyPtr,
        len: len
      )
    } else {
      return nil
    }
  }
}

extension spin_http_string_t {
  var stringValue: String {
    return String(cString: ptr, encoding: .utf8) ?? ""
  }

  init(fromString swiftStr: String) {
    let (ptr, len) = swiftStr.unsafeCharArray
    self.init(ptr: ptr, len: len)
  }
}

extension spin_http_headers_t {
  var dictionaryValue: [String: String] {
    let headersBuffer = UnsafeBufferPointer(start: ptr, count: len)
    return [spin_http_tuple2_string_string_t].init(headersBuffer).reduce(into: [String: String]()) {
      accu, tuple in
      let key = tuple.f0.stringValue
      let value = tuple.f1.stringValue
      accu[key] = value
    }
  }

  func spinOptionHeaders() -> spin_http_option_headers_t {
    return spin_http_option_headers_t(is_some: true, val: self)
  }

  init(fromDict headers: [String: String]) {
    let headerTuples = headers.map({ key, value in
      spin_http_tuple2_string_string_t(
        f0: spin_http_string_t(fromString: key),
        f1: spin_http_string_t(fromString: value)
      )
    })

    let tuplePointer = UnsafeMutablePointer<spin_http_tuple2_string_string_t>.allocate(
      capacity: headerTuples.count)
    tuplePointer.initialize(from: headerTuples, count: headerTuples.count)

    self.init(ptr: tuplePointer, len: headerTuples.count)
  }
}

extension HTTPMethod {
  var wasiOutboundMethod: wasi_outbound_http_method_t {
    return self.rawValue
  }
}

extension String {
  var unsafeCharArray: (UnsafeMutablePointer<CChar>, Int) {
    let cStr = cString(using: .utf8)!
    let len = cStr.count
    let ptr = UnsafeMutablePointer<CChar>.allocate(capacity: len)
    ptr.initialize(from: cStr, count: len)
    return (ptr, len - 1)
  }
}

extension wasi_outbound_http_uri_t {
  init(fromSwiftString swiftStr: String) {
    let (ptr, len) = swiftStr.unsafeCharArray
    self.init(ptr: ptr, len: len)
  }
}

extension URL {
  var wasiOutboundURI: wasi_outbound_http_uri_t {
    return wasi_outbound_http_uri_t(fromSwiftString: self.absoluteString)
  }
}

extension wasi_outbound_http_string_t {
  var stringValue: String {
    return String(cString: ptr, encoding: .utf8) ?? ""
  }

  init(fromString swiftStr: String) {
    let (ptr, len) = swiftStr.unsafeCharArray
    self.init(ptr: ptr, len: len)
  }
}

extension wasi_outbound_http_tuple2_string_string_t {
  init(key: String, val: String) {
    self.init(
      f0: wasi_outbound_http_string_t(fromString: key),
      f1: wasi_outbound_http_string_t(fromString: val))
  }
}

extension wasi_outbound_http_headers_t {
  init(headers: [String: String]) {
    let headerTuples = headers.map(wasi_outbound_http_tuple2_string_string_t.init)

    let tuplePointer = UnsafeMutablePointer<wasi_outbound_http_tuple2_string_string_t>.allocate(
      capacity: headerTuples.count)
    tuplePointer.initialize(from: headerTuples, count: headerTuples.count)

    self.init(ptr: tuplePointer, len: headerTuples.count)
  }
}
