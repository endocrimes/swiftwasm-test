import Foundation
import SpinConfig
import SpinHTTP
import CSpinHTTP

@_cdecl("spin_http_handle_http_request")
func entrypoint(_ rq: SpinRawRequest, _ rs: SpinRawResponse) {
    handleSpinHTTPRequest(rq, rs) { req in
        return HTTPResponse(
            StatusCode: 200,
            Headers: ["content-type": "text/html; charset=utf-8"],
            Body: "<html><h1>Hello</h1><br />This application was written in Swift!<br />The source code is available <a href=\"https://github.com/endocrimes/swiftwasm-test\">here</a></html>\n".data(using: .utf8)
        )
    }
}
