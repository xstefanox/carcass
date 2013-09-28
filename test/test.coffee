asyncTest 'PROPFIND', ->
  
  # create a Carcass client
  c = new Carcass.Client('localhost', 8080)
  
  c.PROPFIND '/resources', 1, null, (success, statusText, root, resources) ->
    
    strictEqual(resources.length, 6, 'Number of resources')
    
    start()
