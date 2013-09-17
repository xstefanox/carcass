asyncTest 'PROPFIND', ->

  c = new Carcass.Client('localhost', 8080)
  
  c.PROPFIND '/', 1, null, (success, statusText, root, resources) ->

    strictEqual(resources.length, 11, 'Number of resources')
    
    start()
