oa = require('oauth/prim')
urllib = require('url')
assert = require('nodeunit/lib/assert')

#
# TODO: unwrap escaping in test cases for legibility.
#

assert.signatureURLEqual = (url, expected) ->
  assert.equal oa.makeSignatureURL(urllib.parse(url)), expected

assert.encodeEqual = (str, expected) ->
  assert.equal oa.encode(str), expected

assert.signatureParameters = (args, expected) ->
  assert.equal oa.makeSignatureParameters.apply(null, args), expected

exports.testMakeSignatureMethod = (test) ->
  test.equal oa.makeSignatureMethod("Get"), "GET"
  test.done()

exports.testMakeSignatureURL = (test) ->
  test.signatureURLEqual "HtTp://LocalHost:80", "http%3A%2F%2Flocalhost%2F"
  test.signatureURLEqual "HtTps://LocalHost:443", "https%3A%2F%2Flocalhost%2F"
  test.signatureURLEqual "HtTp://LocalHost", "http%3A%2F%2Flocalhost%2F"
  test.signatureURLEqual "HtTps://LocalHost", "https%3A%2F%2Flocalhost%2F"
  test.signatureURLEqual "HtTp://LocalHost:80/some/path?q=search#fragment", "http%3A%2F%2Flocalhost%2Fsome%2Fpath"
  test.done()

exports.testEncode = (test) ->
  # unescaped
  test.encodeEqual "-._~-._~", "-._~-._~"
  # RFC5849/3.6 rules (vs RFC3986)
  test.encodeEqual ":/?#[]@!$&'()*+,;=", "%3A%2F%3F%23%5B%5D%40%21%24%26%27%28%29%2A%2B%2C%3B%3D"
  # RFC5849/3.6 rules (url components)
  test.encodeEqual "http://foo:bar@baz/f%o bar?1=2#ok", "http%3A%2F%2Ffoo%3Abar%40baz%2Ff%25o%20bar%3F1%3D2%23ok"
  # four byte UTF-8 sequence
  test.encodeEqual decodeURIComponent("%F0%A4%AD%A2"), "%F0%A4%AD%A2"
  test.done()

exports.testMakeSignatureParameters = (test) ->
  test.signatureParameters([
      { "foo": 12, baz: "one" },
      { "%3d=": 3, baz: ["two", "t.r*e "]},
      { "foo": "01", zorb: '' }
  ], '%25253d%253D%3D3%26baz%3Done%26baz%3Dt.r%252Ae%2520%26baz%3Dtwo%26foo%3D01%26foo%3D12%26zorb%3D')
  test.done()

exports.testMakeSignatureString = (test) ->
  method = "Post"
  url = "Http://Localhost:80/request?b5=%3D%253D&a3=a&c%40=&a2=r%20b"
  body = "c2&a3=2+q"
  oauth = {
    oauth_consumer_key: "9djdj82h48djs9d2",
    oauth_signature_method: "HMAC-SHA1"
  }

  sig = oa.makeSignatureString method, url, oauth, body

  expected = 'POST&http%3A%2F%2Flocalhost%2Frequest&a2%3Dr%2520b%26a3%3D2%2520q%26a3%3Da%26b5%3D' +
              '%253D%25253D%26c%2540%3D%26c2%3D%26oauth_consumer_key%3D9djdj82h48djs9d2%26' +
              'oauth_signature_method%3DHMAC-SHA1'

  test.equal sig, expected
  test.done()

#
# To validate:
#   echo -n zombo | openssl dgst -sha1 -hmac "hello&" -binary | base64
#   echo -n zombo | openssl dgst -sha1 -hmac "%3D&%2F" -binary | base64
#
exports.testHmacSignatureBaseString = (test) ->
  sig = oa.hmacSignatureBaseString "hello", null, "zombo"
  test.equal sig, "4Q7qDUw/kAsUfTuFuuf5JV9DP6w="
  sig = oa.hmacSignatureBaseString "=", "/ ", "zombo"
  test.equal sig, "R5c2ZCw6WAoxO8lOYDpVJ3gZsVE="
  test.done()

#exports.testHmacSignatureBaseString = (test) ->
#  test.equal oa.hmacSignatureBaseString("hi=", "&me"), "hi%3D&%26me"
#  test.done()

exports.testMakeNonce = (test) ->
  test.equal oa.defaultNonceBytes, 32
  oa.defaultNonceBytes = 64
  test.ok oa.makeNonce().match(/^[0-9a-zA-Z]{128}$/)
  test.equal oa.makeNonce(4).length, 8
  test.done()
