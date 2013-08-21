express = require 'express'
require 'express-resource'
require 'express-namespace'

config = require './config/config'
cors = require './middlewares/cors'
stylus = require './middlewares/stylus'
session_expires = 72000000

module.exports = app = express()


#
# App Setting
#

app.configure ->
  app.set 'view engine', 'jade'
  app.set 'views', __dirname + '/views'

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.cookieSession
    secret: 'this is a screen'
    cookie:
      expires : new Date(Date.now() + session_expires)
      maxAge  : session_expires
  app.use cors
  app.use app.router
  app.use stylus
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure 'production', ->
  app.use express.errorHandler()
