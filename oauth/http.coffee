#
# OAuth HTTP support.
#

op = require('./prim')
oh = exports

clone = (obj) ->
  ret = {}
  ret[k] = v for own k, v in obj
  ret

oh.makeAuthorizationHeader = (state, method, url, body, options) ->

  eql = (k, v) ->
    "#{k}=#{v}"

  quote = (v) ->
    "\"#{v}\""

  params = op.makeOAuthParameters(state, method, url, body)
  header = "OAuth "

  if options?.realm
    realm = options.realm.replace /"/, "\\\""
    header += eql "realm", quote(realm)
  params = for own k, v of params
    eql op.encode(k), quote(op.encode(v))

  header += params.join(", ")
  header




