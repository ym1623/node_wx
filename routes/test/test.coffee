wx = require __basename + '/helpers/wx/wx'
http = require 'http'
fs = require 'fs'

module.exports = (app) ->

  app.post '/wx/login', (req, res) ->
    msg = req.body.msg
    fakeids = (req.body.fakeid).split(',')
    wx.login req, (err, cookie) ->
      req.session.is_login = cookie if cookie
      res.json err if err
      for fakeid in fakeids
        data =
          msg    : msg
          fakeid : fakeid
          cookie :  cookie
        wx.sender req, data, (err, results) ->
          res.json err if err
          res.json results

