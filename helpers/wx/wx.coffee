request = require 'superagent'
require __basename + '/helpers/wx/md5'
config = require __basename + '/config/config'
fs = require 'fs'
http = require 'http'

module.exports =
  login: (req, fn) ->
    return fn null, req.session.is_login if req.session.is_login
    wx_usr = config.wx.user
    wx_pwd = md5 config.wx.pwd.substr(0, 16)
    request
      .post('http://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN')
      .type('form')
      .send(
        username: wx_usr
        pwd: wx_pwd
        imgcode : ''
        f : 'json'
        register : 0
      )
      .end (res) ->
        token = res.body.ErrMsg.match(/token=(\d+)/)[1]
        cookie = ''
        if res.header['set-cookie']
          for rs in res.header['set-cookie']
            cookie += rs.replace(/HttpOnly/g, '')

        console.log cookie
        data =
          token : token
          cookie : cookie
        fn null, data

  sender: (req, options, fn) ->
    msg = options.msg
    fakeid = options.fakeid
    token = options.token

    unless msg
      fn error: 'missing msg'
      return

    unless fakeid
      fn error: 'missing fakeid'
      return

    unless token
      fn error : 'missing access_token'

    postParams =
      type: 1
      content: msg
      error: false
      tofakeid : fakeid
      token : token
      ajax : 1


    request
      .post('https://mp.weixin.qq.com/cgi-bin/singlesend?t=ajax-response&lang=zh_CN')
      .type('form')
      .send(postParams)
      .set('Cookie', options.cookie)
      .set('Referer', 'https://mp.weixin.qq.com/cgi-bin/singlesend?t=ajax-response&lang=zh_CN')
      .end (res) ->
        results = JSON.parse res.text
        delete req.session.is_login if results['ret'] is '-20000'
        fn null, results