# -----------------------------------------------------------------------------
# HANDLERS
# -----------------------------------------------------------------------------
  
# The list of handlers of the client requests.
#
Carcass.Handler =
    
  # An empty function used as a common request failure handler.
  #
  failure: ->
    
  # Callback generator for the XMLHttpRequest
  #
  # @param method [String] The method name.
  # @param handler [Function] The handler to execute on request done.
  # @param context [Object] The scope in which the handler will be executed.
  #
  getCallback: (method, handler, context) ->
      
    # return a callback built for the given method
    ->
        
      if this.readyState is XMLHttpRequest.DONE
          
        # on successful request
        if this.status is Carcass.RequestSuccessStatus[method]
            
          handlerResult = Carcass.Handler[method].success.call(this)

          # if a valid handler has been given
          if handler?

            if not handler instanceof Function

              throw new TypeError("Invalid handler")
              
            handlerArgs = [ true, this.statusText ].concat(handlerResult)
              
            # execute the handler, passing the root and the resources
            # returned by the server
            handler.apply(context ? this, handlerArgs)
              
        # on error
        else
            
          handlerResult = Carcass.Handler[method].failure.call(this)

          # if a valid handler has been given
          if handler?

            if not handler instanceof Function

              throw new TypeError("Invalid handler")
              
            handlerArgs = [ false, this.statusText ].concat(handlerResult)
              
            # execute the handler, passing the root and the resources
            # returned by the server
            handler.apply(context ? this, handlerArgs)
  
# Handler for a successful PROPFIND request.
#
Carcass.Handler.PROPFIND =
  
  failure: Carcass.Handler.failure
  success: ->
            
    throw new Carcass.EmptyResponse('PROPFIND') if not this.responseXML?
    
    xpath = new Carcass.XPathResolver(this.responseXML)
    nsResolver = xpath.nsResolver
    # create the namespace resolver from the XML document
    #nsResolver = this.responseXML.createNSResolver(
    #  this.responseXML.documentElement)

    nodes = xpath.getNodeList(Carcass.XPathQuery.RESOURCES)
    
    # get the list of resource nodes in the response
    #nodes = this.responseXML.evaluate(
    #  Carcass.XPathQuery.RESOURCES,
    #  this.responseXML,
    #  nsResolver,
    #  XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
    #  null)

    # create a resource object from each XML resource element and save
    # it into a simple list
    resources = []
    
    for i in [0...nodes.snapshotLength]

      # read the XML element
      node = nodes.snapshotItem(i)

      # create the resource object
      #if this.responseXML.evaluate(
      #  Carcass.XPathQuery.IS_COLLECTION,
      #  node,
      #  nsResolver,
      #  XPathResult.BOOLEAN_TYPE,
      #  null).booleanValue
      
      if xpath.getBoolean(Carcass.XPathQuery.IS_COLLECTION)
        
        currentResource = new Carcass.Collection()
              
      else
              
        currentResource = new Carcass.Resource()

      # set the resource fields
      currentResource.href = xpath.getString(Carcass.XPathQuery.RESOURCE_HREF)
              
      currentResource.ctime = xpath.getString(
        Carcass.XPathQuery.RESOURCE_CTIME)
              
      currentResource.mtime = xpath.getString(
        Carcass.XPathQuery.RESOURCE_MTIME)
              
      currentResource.etag = xpath.getString(
        Carcass.XPathQuery.RESOURCE_ETAG).replace(/(^")|("$)/g, '')
              
      currentResource.mimeType = xpath.getString(
        Carcass.XPathQuery.RESOURCE_MIME_TYPE)
        
      ###
      currentResource.href = this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCE_HREF,
        node,
        nsResolver,
        XPathResult.STRING_TYPE,
        null).stringValue
              
      currentResource.ctime = new Date(this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCE_CTIME,
        node,
        nsResolver,
        XPathResult.STRING_TYPE,
        null).stringValue)
              
      currentResource.mtime = new Date(this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCE_MTIME,
        node,
        nsResolver,
        XPathResult.STRING_TYPE,
        null).stringValue)
              
      currentResource.etag = this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCE_ETAG,
        node,
        nsResolver,
        XPathResult.STRING_TYPE,
        null).stringValue.replace(/(^")|("$)/g, '')
              
      currentResource.mimeType = this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCE_MIME_TYPE,
        node,
        nsResolver,
        XPathResult.STRING_TYPE,
        null).stringValue
      ###

      # the mime type node could not exist if the resource mime type is
      # unknown
      currentResource.mimeType = null if currentResource.mimeType is ''

      # only simple resources have the size field
      if not currentResource instanceof Carcass.Collection

        #currentResource.size = this.responseXML.evaluate(
        #  Carcass.XPathQuery.RESOURCE_SIZE,
        #  node,
        #  nsResolver,
        #  XPathResult.NUMBER_TYPE,
        #  null).numberValue

        currentResource.size = xpath.getNumber(
          Carcass.XPathQuery.RESOURCE_SIZE)

      resources.push(currentResource)
          
    # prepare two lists of resources; they will be filled while
    # searching for the root resource
    indexedResources = []
    unprocessedResources = []
          
    # assume the root is the first node
    root = resources[0]
    rootDepth = root.href.replace(/\/$/, '').split('/').length
          
    # examine all the resources and find the less deepest one
    for resource in resources
            
      # calculate the depth of the current resource
      resourceDepth = resource.href.replace(/\/$/, '').split('/').length
            
      # if the current resource is less deeper than the root
      if resourceDepth < rootDepth
              
        # the current resource is a better candidate for the tree root
        root = resource
        rootDepth = root.href.replace(/\/$/, '').split('/').length

      # remember the current resource
      indexedResources[resource.href] = resource
      unprocessedResources[resource.href] = resource

    # now that have determine the root, consider it as processed, remove it
    # from the list of unprocessed resources and proceed to build the
    # resource tree
    delete(unprocessedResources[root.href])

    # if there are other resources to process
    while Object.keys(unprocessedResources).length > 0

      # for each resource
      for own href, resource of unprocessedResources

        # determine the path of its parent
        tmp = resource.href.replace(/\/$/, '').split('/')
        tmp.pop()
        parentHref = tmp.join('/') + '/'

        # link this resource with its parent
        resource.parent = indexedResources[parentHref]
        resource.parent.members.push(resource)

        # remove this resource from the list
        delete(unprocessedResources[href])
  
    return [ root, resources ]
