
# load modules
assert = require('assert')
fs = require('fs')
temp = require('temp')
jsDAV = require('jsDAV/lib/jsdav')
FSLocksBackend = require('jsDAV/lib/DAV/plugins/locks/fs')
Carcass = require('carcass')

# configure the environment
serverPort = 8000
jsDAV.debugMode = true
sharedResources =
  [ '/public/test1.txt', '/public/test2.txt', '/public/test3.txt' ]

# prepare a function used to start the server when needed
startServer = ->
  
  temp.mkdir null, (err, path) ->
  
    # stop on error
    throw err if err?

    # prepare the test environment
    fs.mkdirSync("#{path}/public")
    fs.openSync("#{path}#{r}", 'w') for r in sharedResources
  
    serverOpts =
      node: "#{path}/public"
      locksBackend: new FSLocksBackend ("#{path}/locks")

    jsDAV.createServer(serverOpts, serverPort)

startServer()


# perform the tests
describe 'Carcass', ->
  
  startServer()
  
  describe 'Listing a folder', ->
    it 'should return 4 resources', ->
      client = new Carcass.Client('localhost', serverPort)
      client.PROPFIND('/', null, null, (success, statusText,
        root, resources) ->
        console.log(resources.length)
        assert.equal(resources.length, sharedResources.length + 1)
      )
      


