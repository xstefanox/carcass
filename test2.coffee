Carcass = require('carcass')

c = new Carcass.Client('localhost', 8000)

c.PROPFIND '/', 'infinity', null, (success, statusText, root, resources) ->
  
  console.log(statusText)
