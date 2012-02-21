oh = require('oauth/http')
op = require('oauth/prim')
urllib = require('url')
assert = require('nodeunit/lib/assert')

exports.testMakeAuthorizationHeader = (test) ->
  state = {
    oauth_consumer_key: "0b2eb1469bcfe10d20a49904"
    oauth_consumer_secret: "b0cae9f3b7206755fb56dd9546f477a9fa0630f9"
    oauth_callback: "oob"
  }
  method = "POST"
  url = urllib.parse("https://api.twitter.com/oauth/request_token", true)

  saved = {
    makeNonce: op.makeNonce
    makeTimestamp: op.makeTimestamp
  }

  op.makeNonce = -> "d1fdf5bd8d40410bc110c007206cfe70808b5b5a91dc443cb961365eea835541"
  op.makeTimestamp = -> "1329806281"

  header = oh.makeAuthorizationHeader state, method, url

  op.makeNonce = saved.makeNonce
  op.makeTimestamp = saved.makeTimestamp

  test.equal header, 'OAuth oauth_consumer_key="0b2eb1469bcfe10d20a49904", oauth_callback="oob", oauth_nonce="d1fdf5bd8d40410bc110c007206cfe70808b5b5a91dc443cb961365eea835541", oauth_timestamp="1329806281", oauth_version="1.0", oauth_signature_method="HMAC-SHA1", oauth_signature="zq%2B%2BZYEgdUEKJJQylEuv7UoXi%2F0%3D"'
  test.done()
