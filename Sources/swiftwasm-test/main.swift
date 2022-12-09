import Foundation
import CSpinHTTP
import CSpinConfig

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

func SpinConfigGet(key: String) throws -> String {
    var spinResponse = spin_config_expected_string_error_t.init()
    let cKeyStr = key.cString(using: .utf8)
    let cKey = UnsafeMutablePointer(mutating: cKeyStr)
    var spinKey = spin_config_string_t(ptr: cKey, len: key.count)
    defer {
        cKey?.deallocate()
    }
    spin_config_get_config(&spinKey, &spinResponse)
    if spinResponse.is_err {
        let spinErr = spinResponse.val
        throw "error fetching config: \(spinErr)"
    }
    return ""
}

@_cdecl("spin_http_handle_http_request")
func C_handleHTTPRequest(_ reqPtr: UnsafeMutablePointer<spin_http_request_t>, _ resPtr: UnsafeMutablePointer<spin_http_response_t>)  {
    defer {
        spin_http_request_free(reqPtr)
    }
//    let request = reqPtr.pointee
    resPtr.pointee.status = 200
    resPtr.pointee.body.is_some = true
    let respStr = "Hello from Swift via CursedFFI\n"
    let respBodyData = Array(respStr.data(using: .utf8)!)
    let respBodyPtr = UnsafeMutablePointer(mutating: respBodyData)
    var respBody = spin_http_body_t(ptr: respBodyPtr, len: respBodyData.count)
    resPtr.pointee.body.val = respBody
    
}
