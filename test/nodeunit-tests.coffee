Carcass = require('build/carcass')

exports.PROPFIND = (test) ->

  c = new Carcass.Client('localhost', 8080)
  
  c.PROPFIND '/', 1, null, (success, statusText, root, resources) ->

    test.strictEqual(resources.length, 6, 'Number of resources')
    
    test.done()
