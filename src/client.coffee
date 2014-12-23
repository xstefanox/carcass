# -----------------------------------------------------------------------------
# CLIENT
# -----------------------------------------------------------------------------

# Creates a new Carcass client.
#
class Carcass.Client
  
  # Construct a new Carcass Client.
  #
  # @param host [String] the host name or IP address of the Carcass share.
  # @param port [Number] TCP port of the host.
  # @param protocol [String] protocol part of URLs.
  # @param user [String] optional user name to use for authentication purposes.
  # @param password [String] optional password to use for authentication
  #        purposes.
  constructor: (@host, @port, @protocol, @user, @password) ->

    # check for prerequisites
    throw new Carcass.MustacheNotFound() if not Mustache?
    throw new Carcass.XHRNotSupported() if not XMLHttpRequest?
    
    # these are the XMLHttpRequest return codes
    statuses =
      UNSENT: 0
      OPENED: 1
      HEADERS_RECEIVED: 2
      LOADING: 3
      DONE: 4
    
    # fix XMLHttpRequest return statuses if they are not defined
    XMLHttpRequest[s] = v for own s,v of statuses when not XMLHttpRequest[s]?
      
    # if running in a browser environment, fallback to the location object
    if location?
      @host ?= location.hostname
      @port ?= location.port
      @protocol ?= location.protocol.replace(':', '')
      
    # fallback to the defaults
    @host ?= Carcass.DEFAULT_HOST
    @port ||= Carcass.DEFAULT_PORT
    @protocol ?= Carcass.DEFAULT_PROTOCOL
    
    # check if the port is actually a number: try to cast to a number in a
    # temporary value and if this fails, raise an error, else save the
    # converted value
    port = Number(@port)
    if isNaN(@port) or !@port
      throw new TypeError("Invalid port number '#{port}'")
    @port = port

  # Return a string description of this object, useful when printing the
  # object to the console.
  #
  # @return [String] A string description of this object.
  #
  toString: ->
    return "[object Carcass.Client]"

  # Open the connection.
  #
  # @param method [String] A valid HTTP method.
  # @param path [String] The destination url.
  #
  open: (method, path) ->
    
    # check if the method is supported
    if method not in Carcass.WEBDAV_METHODS
      throw new Carcass.UnsupportedMethod(method)
    
    # if the path is not absolute, prefix it with a '/' character
    path = "/#{path}" if not /^\/.*/.test(path)
    
    # make the path absolute
    path = "#{@protocol}://#{@host}:#{@port}#{path}"
      
    # create the request object
    xhr = new XMLHttpRequest()
    xhr.timeout = Carcass.DEFAULT_TIMEOUT
      
    # this request is always asynchronous (the last argument is always true)
    xhr.open(method, path, true, @user, @password)
      
    return xhr

  # Set the value of the Lock header
  #
  # @param xhr [XMLHttpRequest] The XHR request.
  # @param lockToken [String] The lock token.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  setLock: (xhr, lockToken) ->
    
    # set the lock token if given
    xhr.setRequestHeader('If', "<#{lockToken}>") if lockToken
    
    @

  # Set the content type of the body
  #
  # @param xhr [XMLHttpRequest] The XHR request.
  # @param charset [String] The charset.
  #
  # @return [String] The calculated charset.
  #
  setCharset: (xhr, charset) ->
    
    # determine the document character set and send the request with the same
    # setting; if in a browser environment, try the standard property first,
    # then try the MSIE non-standard property; eventually fall back to UTF-8
    if document?
      charset ?= document.characterSet
      charset ?= document.charset
    charset ?= Carcass.DEFAULT_CHARSET
    xhr.setRequestHeader("Content-type", "text/xml; charset=#{charset}")
    
    return charset

  # Read the properties data structure and return the list of namespaces.
  #
  # @param properties [Array] The list of properties to analyze.
  #
  # @return [Array] The list of namespaces and schemas found.
  #
  readNamespaces: (properties) ->
    
    namespaces = []    # the result value
    schemas = []       # the list of schemas
    
    # create a recursive function that walks through the given properties
    f = (properties, schemas) ->

      # if item is an object, ensure it is contained into an array, to ease our
      # work
      properties = [ properties ] if properties not instanceof Array

      # create a list of schemas and namespaces that will be used in the
      # generated XML; this list is indexed by schema url
      for property in properties

        # if the 'name' property is empty or undefined
        if not property.name

          # ignore this property
          delete properties[properties.indexOf(property)]

        else

          # if the element schema is defined
          if property.schema?

            # if the schema is not present in the schema list
            if not schemas[property.schema]?

              # add the schema
              schemas[property.schema] =
                ns: 'ns' + (s for own s of schemas).length
                schema: property.schema

            # add the calculated xml namespace to the property element
            property.ns = schemas[property.schema].ns

            # recursively read the nested fields' schemas
            # if the element has some nested fields
            f(property.fields, schemas) if property.fields?
          
          # else don't set any explicit schema and fall back to the default
          # Carcass schema
  
    if properties?
        
      # analyze the properties
      f(properties, schemas)

      # remove the indexes from the list and obtain a plain array, which is
      # needed by Mustache
      for own name, schema of schemas
        namespaces.push(schema)
    
    return namespaces

  # Retrieve the contents of a resource.
  #
  # @param path [String] The path to the requested resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  GET: (path, handler, context) ->
    
    xhr = @open('GET', path)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'GET', handler, context)
        
    xhr.send()
    
    @

  # Save the contents of a resource to the server.
  #
  # @param path [String] The path to the requested resource.
  # @param content [String] The new content of the resource.
  # @param charset [String] The character encoding of the request.
  # @param lockToken [String] The token for the locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  PUT: (path, content, charset, lockToken, handler, context) ->
    
    xhr = @open('PUT', path)
    
    @setCharset(xhr, charset)
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'PUT', handler, context)
    
    xhr.send(content)
    
    @

  # Remove a resource. It acts recursively if the resource is a collection.
  #
  # @param path [String] The path to the requested resource.
  # @param lockToken [String] The token for the locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  DELETE: (path, lockToken, handler, context) ->
    
    xhr = @open('DELETE', path)
    
    # Infinity depth is the default for the DELETE method and the only
    # accepted value; it is not required, so we won't send it and fall back
    # to the default
    #request.setRequestHeader("Depth", "Infinity")
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'DELETE', handler, context)
    
    xhr.send()
    
    @

  # Create a collection.
  #
  # @param path [String] The path to the requested resource.
  # @param lockToken [String] The token for the locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  MKCOL: (path, lockToken, handler, context) ->
    
    xhr = @open('MKCOL', path)
    
    @setLock(xhr, lockToken)
    
    # @TODO: MKCOL may contain a message body

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'MKCOL', handler, context)
    
    xhr.send()
    
    @

  # Create a copy of a resource.
  #
  # @param sourcePath [String] The path to the resource that will be copied.
  # @param destinationPath [String] The destination path of the copy.
  # @param lockToken [String] The token for the locked resource.
  # @param overwrite [Boolean] Whether he destination should be overwritten
  #        if exists.
  # @param recursive [Boolean] Whether the copy of a collection should be
  #        performed recursively.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  COPY: (sourcePath, destinationPath, lockToken, overwrite,
         recursive, handler, context) ->
  
    xhr = @open('COPY', sourcePath)
    
    xhr.setRequestHeader('Destination', destinationPath)
  
    xhr.setRequestHeader('Overwrite', if overwrite then 'T' else 'F')
    
    xhr.setRequestHeader('Depth', if recursive then 'Infinity' else '0')
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'COPY', handler, context)
    
    xhr.send()
    
    @

  # Move a resource from a location to another.
  #
  # @param sourcePath [String] The path to the resource that will be moved.
  # @param destinationPath [String] The destination path.
  # @param lockToken [String] The token for the locked resource.
  # @param overwrite [Boolean] Whether the destination should be overwritten
  #        if exists.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  MOVE: (sourcePath, destinationPath, lockToken,
         overwrite, handler, context) ->
    
    xhr = @open('MOVE', sourcePath)
    
    xhr.setRequestHeader("Destination", destinationPath)
    
    xhr.setRequestHeader('Overwrite', if overwrite then 'T' else 'F')
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'MOVE', handler, context)
    
    xhr.send()
    
    @

  # Read the metadata of a resource, optionally including its members.
  #
  # @param path [String] The path to the resource that will be queried.
  # @param depth [Number, String] The depth downto which the resource will be
  #        queried, if it is a collecion.
  # @param properties [Array<Object>] The list of properties that will be
  #        queried. The array must contain elements of the form { name:
  #        'property name', schema: 'XML schema url' }. If an element does
  #        not contain the 'name' property, it is ignored. If an element does
  #        not contain the 'schema' property, no schema is used and the
  #        protocol will fall back to the default Carcass namespace. If no
  #        property is given, all the resource properties will be fetched.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  PROPFIND: (path, depth, properties, handler, context) ->

    xhr = @open('PROPFIND', path)

    # if a depth has been given
    if depth?
      
      # check if the given depth is infinity
      depthIsInfinity = depth.toLowerCase? and
        depth.toLowerCase() is 'infinity'

      # fail if the given value is invalid
      if not (depthIsInfinity or depth is 0 or depth is 1)

        throw new Carcass.InvalidDepth(depth)
        
      xhr.setRequestHeader('Depth', depth)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'PROPFIND', handler, context)
              
    xhr.send(Mustache.render(
      Carcass.RequestTemplate.PROPFIND_BODY,
      {
        encoding: @setCharset(xhr),
        webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
        haveProperties: properties instanceof Array and properties.length,
        properties: properties,
        namespaces: @readNamespaces(properties)
      }
    ))
    
    @

  # Set and/or remove properties of a resource.
  #
  # @param path [String] The path to the resource that will be modified.
  # @param setProperties [Array] The properties that will be set on the
  #        resource.
  # @param deleteProperties [Array<Object>] The properties that will be deleted
  #        from the resource. The array must contain elements of the form
  #        { name: 'property name', schema: 'XML schema url' }. If an element
  #        does not contain the 'name' property, it is ignored. If an element
  #        does not contain the 'schema' property, no schema is used and the
  #        protocol will fall back to the default Carcass namespace.
  # @param lockToken [String] The token for the locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  PROPPATCH: (path, setProperties, deleteProperties,
              lockToken, handler, context) ->

    xhr = @open('PROPPATCH', path)
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'PROPPATCH', handler, context)

    xhr.send(Mustache.render(
      Carcass.RequestTemplate.PROPPATCH_BODY,
      {
        encoding: @setCharset(xhr),
        webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
        setProperties: setProperties,
        deleteProperties: deleteProperties,
        namespaces: @readNamespaces(setProperties)
      },
      {
        value: Carcass.RequestTemplate.PROPPATCH_VALUE
      }
    ))
    
    @

  # Lock a resource.
  #
  # @param path [String] The resource to lock.
  # @param owner [String] An URL identifying the owner of the lock.
  # @param scope [String] The scope of the lock. Accepted values are listed
  #        in Carcass.Scope.
  # @param lockType [String] The type of the lock. Accepted values are listed
  #        in Carcass.LockType.
  # @param depth [Number, String] The depth of the lock. Accepted values:
  #        '0', 'Infinity'.
  # @param timeout [Number] The timeout in seconds of the lock.
  # @param lockToken [String] The token for the locked resource. If given,
  #        refreshes an already locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  LOCK: (path, owner, scope, lockType, depth,
         timeout, lockToken, handler, context) ->

    # validate the scope value
    if not Carcass.Scope[scope]?
      throw new Carcass.InvalidScope(scope)
    
    # 'write' is the only value accepted by the protocol
    if not Carcass.LockType[lockType]
      throw new Carcass.InvalidLockType(lockType)
    
    xhr = @open('LOCK', path)
    
    # if a depth has been given
    if depth?
    
      # check if the given depth is infinity
      depthIsInfinity = depth.toLowerCase? and
        depth.toLowerCase() is 'infinity'
      
      # fail if the given value is invalid
      if not (depthIsInfinity or depth is 0)
        throw new Carcass.InvalidDepth(depth)
        
      xhr.setRequestHeader('Depth', depth)
    
    if lockToken
      @setLock(xhr, lockToken)
    else
      # if no timeout is given, try to request an infinite timeout or the
      # maximum supported timeout at least
      if not timeout?
        timeout = "Infinite, Second-#{Carcass.HEADER_TIMEOUT_MAX}"
      else
        timeout = 'Second-' + timeout
        
      xhr.setRequestHeader('Timeout', timeout)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'LOCK', handler, context)

    xhr.send(Mustache.render(Carcass.RequestTemplate.LOCK_BODY,
    {
      encoding: @setCharset(xhr),
      webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
      scope: scope,
      type: lockType,
      owner: owner
    }))
    
    @

  # Unlock a resource.
  #
  # @param path [String] The path to the resource that will be modified.
  # @param lockToken [String] The token for the locked resource.
  # @param handler [Function] The function called when on request completion.
  # @param context [Object] The context in which the handler will be executed.
  #
  # @return [Carcass.Client] A reference to this object.
  #
  UNLOCK: (path, lockToken, handler, context) ->

    xhr = @open('UNLOCK', path)
    
    @setLock(xhr, lockToken)

    # set the callback for the request
    xhr.onreadystatechange = Carcass.Handler.getCallback(
      'UNLOCK', handler, context)
    
    xhr.send()
    
    @
