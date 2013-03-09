asyncTest 'PROPFIND', ->

  c = new Carcass.Client('localhost', 8000)
  
  c.PROPFIND '/', 1, null, (success, statusText, root, resources) ->

    strictEqual(resources.length, 9, 'Number of resources')
    
    start()
