util = require "util"
module.exports = class SessionSIO
  constructor: (@io, @sessionStore, @cookieParser, @key = "connect.sid") ->


  getSession: (socket, callback) ->
    @cookieParser socket.handshake, {}, (parseErr) =>
      id = @findCookie(socket.handshake)
      @sessionStore.get id, (storeErr, session) =>
        err = @resolve(parseErr, storeErr, session)
        session.id = id  if session
        callback err, session

  bind: (event, callback, namespace) ->
    namespace.on event, (socket) =>
      @getSession socket, (err, session) ->
        callback err, socket, session

  findCookie: (handshakeInput) =>
    key = @key
    # fix for express 4.x (parse the cookie sid to extract the correct part)
    handshake = JSON.parse(JSON.stringify(handshakeInput)) # copy of object
    handshake.secureCookies = (handshake.secureCookies[key].match(/\:(.*)\./) or []).pop()  if handshake.secureCookies and handshake.secureCookies[key]
    handshake.signedCookies[key] = (handshake.signedCookies[key].match(/\:(.*)\./) or []).pop()  if handshake.signedCookies and handshake.signedCookies[key]
    handshake.cookies[key] = (handshake.cookies[key].match(/\:(.*)\./) or []).pop()  if handshake.cookies and handshake.cookies[key]
    # original code
    (handshake.secureCookies and handshake.secureCookies[key]) or (handshake.signedCookies and handshake.signedCookies[key]) or (handshake.cookies and handshake.cookies[key])

  resolve: (parseErr, storeErr, session) ->

    return parseErr  if parseErr
    return new Error("could not look up session by key: #{@key}")  if not storeErr and not session
    return storeErr

  of: (namespace) ->
    on: (event, callback) =>
      @bind event, callback, @io.of(namespace)

  on: (event, callback) =>
    @bind event, callback, @io.sockets
