window.ac = ac = null

module "EMailAutoComplete",
  setup: () ->
    window.ac = ac = new EMailAutoComplete()

test "EMailAutoComplete.parseEmail", () ->

  console.log("starting...")

  tests =
    "niall@pobox@com":
      null
    "\"niall\" <niall@pobox@com>":
      null
    "niall@pobox.com,greenfield@pobox.com":
      null
    "niall@pobox.com;greenfield@pobox.com":
      null
    "niall@pobox.com":
      name: null
      email: "niall@pobox.com"
    "\"niall smart\" <niall@pobox.com>":
      name: "niall smart"
      email: "niall@pobox.com"
    "'niall smart' <niall@pobox.com>":
      name: "niall smart"
      email: "niall@pobox.com"

  console.log(tests)

  for own email, expected of tests
    console.log(email, expected)
    ret = ac.parseEmail(email)
    if !expected?
      equal ret, null, "null result expected for #{email}"
    else if !ret?
      ok false, "not-null result expected for #{email}"
    else
      equal ret.email, expected.email
      equal ret.name, expected.name
