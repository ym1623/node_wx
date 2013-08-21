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

  cover_img:  (options, fn) ->
    req = request
      .post('https://mp.weixin.qq.com/cgi-bin/uploadmaterial?cgi=uploadmaterial&type=0&token=315392323&t=iframe-uploadfile&lang=zh_CN&formId=null')

    part = req.part().set("Content-Type", "image/png").set("Content-Disposition", "attachment; filename=\"another.png\"")

    req.end (res) ->
      console.log res


    # request
    #   .post('http://mp.weixin.qq.com/cgi-bin/uploadmaterial')
    #   # .attach('uploadfile', options.uploadfile)
    #   .type('form')
    #   .set('Cookie', options.cookie)
    #   .set('Content-Disposition', 'attachment; name="uploadfile"; filename="http://192.168.211.166:8080/uploads/爱婴岛.png"')
    #   .set('Referer', 'https://mp.weixin.qq.com/cgi-bin/indexpage?token='+options.token+'&lang=zh_CN&t=wxm-upload&lang=zh_CN&type=0&fromId=file_from_1341151893625')
    #   .send(
    #     cgi: 'uploadmaterial'
    #     type: 0
    #     token : options.token
    #     t : 'iframe-uploadfile'
    #     lang : 'zh_CN'
    #     formId : null
    #   )
    #   .end (res) ->
    #     console.log res
    #     fn null, res.text
        # results = JSON.parse(res.text).match(/formId, '(\d+)'/)[2]
        # fn null, results

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