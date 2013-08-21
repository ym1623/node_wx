wx = require __basename + '/helpers/wx/wx'
http = require 'http'
fs = require 'fs'
helper = require __basename + '/helpers/common'

module.exports = (app) ->

  app.post '/wx/login', (req, res) ->
    msg = req.body.msg
    fakeid = req.body.fakeid
    wx.login req, (err, results) ->
      req.session.is_login = results if results
      res.json err if err
      data =
        msg : msg
        fakeid : fakeid
        cookie : results.cookie
        token : results.token

      wx.sender req, data, (err, results) ->
        res.json err if err
        res.json results

  app.post '/wx/upload', (req, res) ->
    file = req.files.uploadfile
    tmp_path = file.path
    target_path = __basename + '/public/uploads/' + file.name
    create_file = 'public/uploads/'
    helper.mkdirSync create_file, 0, (e) ->
      console.log '出错了' if e
    fs.rename tmp_path, target_path, (err) ->
      throw err  if err
      fs.unlink tmp_path, ->
        throw err  if err

        wx.login req, (err, results) ->
          # req.session.is_login = results if results
          data = 
            cookie : results.cookie
            token : results.token
            # uploadfile : uploadfile
          wx.cover_img data, (err, results) ->
            res.json results