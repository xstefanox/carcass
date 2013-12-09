describe 'PROPFIND', ->
  
  it 'tests a simple directory listing', ->
    
    # create a Carcass client
    c = new Carcass.Client('localhost', 8080)
    
    runs ->
      
      c.PROPFIND(
        '/resources', 1, null, (success, statusText, root, resources) ->
    
        expect(resources.length).toEqual(6, 'Number of resources')
      )
        #start()
