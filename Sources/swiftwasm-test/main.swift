import SpinHTTP

spinHandler = { req in
  return HTTPResponse(
    statusCode: 200,
    headers: [
      "content-type": "text/html; charset=utf-8"
    ],
    body:
      "<html><h1>Hello</h1><br />Welcome to Spin!<br />The source code is available <a href=\"https://github.com/endocrimes/swiftwasm-test\">here</a></html>\n"
  )
}
