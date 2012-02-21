#
# OAuth primitives.
#

urllib = require('url')
qslib = require('querystring')
crypto = require('crypto')
oa = exports

oa.defaultPorts = {
  "http:":   80,
  "https:":  443
}

oa.defaultNonceBytes = 32

#
# Creates an OAuth signature base string for a HTTP request.
#
# @param method the HTTP method.
# @param url the URL string (including hostname, path and query string parameters)
# @param oauth the OAuth authentication parameters for this request (Object)
# @param body the request body (x-www-form-urlencoded String, or Object) if applicable
#
oa.makeSignatureString = (method, url, oauth, body) ->

  url = urllib.parse(url, true) if typeof(url) == 'string'
  body = qslib.parse(body) if typeof(body) == 'string'

  [oa.makeSignatureMethod(method),
    oa.makeSignatureURL(url),
    oa.makeSignatureParameters(url.query, oauth, body)].join("&")

oa.makeSignatureMethod = (method) ->
  method.toUpperCase()

oa.makeSignatureURL = (url) ->
  url = urllib.parse(url, true) if typeof(url) == 'string'
  scheme = url.protocol.toLowerCase()
  hostname = url.hostname.toLowerCase()
  port = if !url.port || parseInt(url.port) == oa.defaultPorts[scheme] then "" else ":#{url.port}"
  pathname = url.pathname || "/"
  oa.encode("#{scheme}//#{hostname}#{port}#{pathname}")

oa.makeSignatureParameters = (qs, oauth, body) ->
  params = []

  collect = (obj) ->
    for own k, vs of obj
      vs = [vs] unless vs instanceof Array
      for v in vs
        params.push({key: oa.encode(k), value: oa.encode(v)})

  collect(qs)
  collect(oauth)
  collect(body)

  params.sort (l, r) ->
    field = if l.key == r.key then "value" else "key"
    l[field].localeCompare(r[field])

  params = params.map( (kv) ->
    "#{kv.key}=#{kv.value}"
  ).join("&")

  oa.encode(params)

oa.encode = (str) ->
  ret = encodeURIComponent(str)
  ret = ret.replace(/!/g, '%21')
  ret = ret.replace(/'/g, '%27')
  ret = ret.replace(/\(/g, '%28')
  ret = ret.replace(/\)/g, '%29')
  ret = ret.replace(/\*/g, '%2A');
  ret

oa.hmacSignatureBaseString = (clientSecret, tokenSecret, signatureBaseString) ->
  key = [oa.encode(clientSecret), oa.encode(tokenSecret || "")].join("&")
  hmac = crypto.createHmac("sha1", key)
  hmac.update(signatureBaseString)
  hmac.digest("base64")

oa.hmac = (clientSecret, tokenSecret, method, url, oauth, body) ->
  sbs = oa.makeSignatureString(method, url, oauth, body)
  oa.hmacSignatureBaseString(clientSecret, tokenSecret, sbs)

oa.makeNonce = (bytes) ->
  crypto.randomBytes(bytes || oa.defaultNonceBytes).toString('hex')

oa.makeTimestamp = ->
  Math.floor(Date.now() / 1000).toString()

oa.makePlaintextSignature = (clientSecret, tokenSecret) ->
  [oa.encode(clientSecret), oa.encode(tokenSecret || "")].join("&")

oa.makeOAuthParameters = (state, method, url, body) ->
  oauth = {}
  oauth.oauth_consumer_key = state.oauth_consumer_key
  oauth.oauth_token = state.oauth_token if state.oauth_token?
  oauth.oauth_verifier = state.oauth_verifier if state.oauth_verifier?
  oauth.oauth_callback = state.oauth_callback if state.oauth_callback
  oauth.oauth_nonce = oa.makeNonce()
  oauth.oauth_timestamp = oa.makeTimestamp()
  oauth.oauth_version = "1.0"
  oauth.oauth_signature_method = "HMAC-SHA1"
  oauth.oauth_signature = oa.hmac(
      state.oauth_consumer_secret,
      state.oauth_token_secret,
      method,
      url,
      oauth,
      body
  )
  oauth
