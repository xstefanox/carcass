root = '/resources'

asyncTest 'PROPFIND', ->
  
  # create a Carcass client
  c = new Carcass.Client('localhost', 8080)

  # fetch only the resources on the first level of the resource tree
  depth = 1
  c.PROPFIND root, depth, null, (success, statusText, root, resources) ->
    
    strictEqual(resources.length, 6, 'Number of resources')
    
    start()