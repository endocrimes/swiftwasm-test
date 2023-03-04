import Spin

let router = Router()
  .get(
    "/api/v1/facts/:id",
    { req in
      return try HTTPResponse(
        statusCode: 200,
        JSON: [
          "id": req.params.get("id")!,
          "fact": "i have no database yet, no facts here.",
        ]
      )
    }
  )
  .get(
    "/",
    { req in
      return HTTPResponse(
        statusCode: 200,
        headers: [
          "content-type": "text/html; charset=utf-8"
        ],
        body:
          "<html><h1>Hello</h1><br />Welcome to Spin!<br />The source code is available <a href=\"https://github.com/endocrimes/swiftwasm-test\">here</a></html>\n"
      )
    }
  )

spinHandler = router.run
