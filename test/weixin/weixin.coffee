describe 'product@account', ->

  str = 'hello '

  # test to before
  before () ->
    str+='world'

  it 'should test my mocha with projects', (done) ->
    str.should.equal 'hello world'
    done()

describe 'product@ym', ->

  str = 'hello '

  # test to before
  before () ->
    str+='world'

  it 'should test my mocha with projects', (done) ->
    str.should.equal 'hello world'
    done()