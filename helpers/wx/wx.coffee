request = require 'superagent'
require __basename + '/helpers/wx/md5'
config = require __basename + '/config/config'
fs = require 'fs'
http = require 'http'

module.exports =
  login: (req, fn) ->
    # return fn null, req.session.is_login if req.session.is_login
    wx_usr = config.wx.user
    wx_pwd = md5 config.wx.pwd.substr(0, 16)
    request
      .post('https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN')
      .type('form')
      .set('Referer', 'https://mp.weixin.qq.com/cgi-bin/singlesend?t=ajax-response&lang=zh_CN')
      .send(
        username: wx_usr
        pwd: wx_pwd
        imgcode : ''
        f : 'json'
      )
      .end (res) ->
        token = res.body.ErrMsg.match(/token=(\d+)/)[1]
        cookie = ''
        if res.header['set-cookie']
          for rs in res.header['set-cookie']
            cookie += rs.replace(/HttpOnly/g, '')
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
      .set('Referer', 'https://mp.weixin.qq.com/cgi-bin/singlemsgpage')
      .end (res) ->
        results = JSON.parse res.text
        delete req.session.is_login if results['ret'] is '-20000'
        fn null, results

  getFriendPage: (req, results, fn) ->
    request
      .get('https://mp.weixin.qq.com/cgi-bin/contactmanagepage?token='+results.token+'&t=wxm-friend&lang=zh_CN&pagesize=10000&pageidx=0&type=0&groupid=0')
      .set('Cookie', results.cookie)
      .end (res) ->
        console.log res.text
        rs = res.text.replace(/document.location.hostname.match.*\[0\]/g, '"'+req.host+'"')
        results = rs.match(/<script id="json-friendList" .*>([\s\S]*?)<\/script>/)[1]
        fn null, JSON.parse results

  getInfo: (fakeid, results, fn) ->
    postParams =
      token : results.token
      ajax : 1

    request
      .post('https://mp.weixin.qq.com/cgi-bin/getcontactinfo?t=ajax-getcontactinfo&lang=zh_CN&fakeid=' + fakeid)
      .type('form')
      .send(postParams)
      .set('Cookie', results.cookie)
      .set('Referer', 'https://mp.weixin.qq.com/cgi-bin/singlesend')
      .end (res) ->
        fn null, JSON.parse res.text
