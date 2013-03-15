app = require './app'
optimist = require 'optimist'
http = require 'http'
config = require './config/config'

argv = optimist
  .options 'p',
    alias: 'port'
    default: 8080
  .options 'f',
    alias: 'force'
  .argv

#
# Server Listening
#

module.exports = server = http.createServer app

if process.env.NODE_ENV isnt 'test' or argv.force
  server.listen argv.port, ->
    console.log "Express server listening on port %d in %s mode", argv.port, app.settings.env

#
# Router Setting
#

require './router'

#
# Error handler
#

process.on 'uncaughtException', console.dir
