###
@license The MIT License
@author Stefano Varesi
###

# @TODO handler management
# @TODO MKCOL body


###############################################################################
# UNIVERSAL MODULE DEFINITION
###############################################################################

publisher = (global, factory) ->
  if typeof exports is 'object'
    # CommonJS
    factory(
      exports,
      require('mustache'),
      require('xmlhttprequest').XMLHttpRequest)
  else if typeof define is 'function' and define.amd?
    # AMD
    define([ 'exports', 'mustache' ], factory)
  else
    # Browser
    factory((global.Carcass = {}), global.Mustache, global.XMLHttpRequest)

publisher this, (Carcass, Mustache, XMLHttpRequest) ->

  #############################################################################
  # NAMESPACE
  #############################################################################
  
  # Carcass namespace.
  #
  # @mixin
  #
  # Dependencies:
  #  Mustache
  #
  # Required ES5 features:
  #  Object.keys
  #Carcass = {}
  
  #############################################################################
  # EXCEPTIONS
  #############################################################################
  
  # Exception thrown when the Mustache library is not loaded.
  #
  class Carcass.MustacheNotFound extends Error
  
    constructor: ->
      @name = 'Carcass.MustacheNotFound'
      @message = 'Mustache templating library not loaded'

  # Exception thrown when the browser does not support asynchronous requests.
  #
  class Carcass.XHRNotSupported extends Error
  
    constructor: ->
      @name = 'Carcass.XHRNotSupported'
      @message = 'Your environment lacks the XHR support'

  # Exception thrown when the value for the Depth header is not valid.
  #
  class Carcass.InvalidDepth extends RangeError
  
    # Construct a new InvalidDepth exception.
    #
    # @param depth [Number, String] The given invalid depth.
    #
    constructor: (depth) ->
      @name = 'Carcass.InvalidDepth'
      @message = depth

  # Exception thrown when the value for the scope element is not valid.
  #
  class Carcass.InvalidScope extends Error
  
    # Construct a new InvalidScope exception.
    #
    # @param scope [Object] The given invalid scope.
    #
    constructor: (scope) ->
      @name = 'Carcass.InvalidScope'
      @message = scope

  # Exception thrown when the value for the lock type is not valid.
  #
  class Carcass.InvalidLockType extends Error

    # Construct a new InvalidLockType exception.
    #
    # @param type [Object] The given lock type.
    #
    constructor: (type) ->
      @name = 'Carcass.InvalidLockType'
      @message = type

  # Exception thrown when the response status is not valid for the request
  # method.
  #
  class Carcass.UnexpectedResponseStatus extends Error
  
    # Construct a new UnexpectedResponseStatus exception
    #
    # @param status [Number] The response status.
    # @param method [String] The HTTP method of the request.
    #
    constructor: (status, method) ->
      @name = 'Carcass.UnexpectedResponseStatus'
      @message = "#{status} #{Carcass.HTTP_STATUS_CODES[status]}, " +
                 "method '#{method}'"

  # Exception thrown when trying to open a connection using a HTTP method
  # invalid or unsupported by the WebDAV protocol.
  #
  class Carcass.UnsupportedMethod extends Error
  
    # Construct a new UnsupportedMethod exception.
    #
    # @param method [String] The requested method.
    #
    constructor: (method) ->
      @name = 'Carcass.UnsupportedMethod'
      @message = "Unsupported WebDAV method: #{method}"

  # Exception thrown when the server returned an empty response.
  #
  class Carcass.EmptyResponse extends Error
    
    # Construct a new EmptyResponse exception.
    #
    # @param method [String] The request method.
    #
    constructor: (method) ->
      @name = 'Carcass.EmptyResponse'
      @message = "The server returned an empty response for the #{method} " +
                 "request"
  
  #############################################################################
  # CONSTANTS
  #############################################################################
  
  # The library name.
  #
  Carcass.NAME = 'Carcass.js'

  # The library version.
  #
  Carcass.VERSION = '0.1-alpha'

  # HTTP status codes reference.
  #
  # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10
  #
  # The listed status codes are from HTTP/1.1 specification, RFC 2616, except
  # where other RFCs or extensions are specified.
  #
  # Other referenced RFCs:
  # RFC 4918: HTTP Extensions for Web Distributed Authoring and Versioning
  #           (WebDAV)
  # RFC 5842: Binding Extensions to Web Distributed Authoring and Versioning
  #           (WebDAV)
  # RFC 3229: Delta encoding in HTTP
  # RFC 2324: Hyper Text Coffee Pot Control Protocol (HTCPCP/1.0)
  # RFC 3648: Web Distributed Authoring and Versioning (WebDAV)
  #           Ordered Collections Protocol
  # RFC 2817: Upgrading to TLS Within HTTP/1.1
  # RFC 6585: Additional HTTP Status Codes
  # RFC 2295: Transparent Content Negotiation in HTTP
  # RFC 2774: An HTTP Extension Framework
  #
  Carcass.HTTP_STATUS_CODES =
    100: 'Continue'
    101: 'Switching Protocols'
    102: 'Processing'                           # RFC 4918
    200: 'OK'
    201: 'Created'
    202: 'Accepted'
    203: 'Non-Authoritative Information'
    204: 'No Content'
    205: 'Reset Content'
    206: 'Partial Content'
    207: 'Multi-Status'                         # RFC 4918
    208: 'Already Reported'                     # RFC 5842
    226: 'IM Used'                              # RFC 3229
    300: 'Multiple Choices'
    301: 'Moved Permanently'
    302: 'Found'
    303: 'See Other'
    304: 'Not Modified'
    305: 'Use Proxy'
    306: 'Switch Proxy'
    307: 'Redirect'
    308: 'Permanent Redirect'                # draft-reschke-http-status-308-07
    400: 'Bad Request'
    401: 'Unauthorized'
    402: 'Payment Required'
    403: 'Forbidden'
    404: 'Not Found'
    405: 'Method Not Allowed'
    406: 'Not Acceptable'
    407: 'Proxy Authentication Required'
    408: 'Request Time-out'
    409: 'Conflict'
    410: 'Gone'
    411: 'Length Required'
    412: 'Precondition Failed'
    413: 'Request Entity Too Large'
    414: 'Request-URI Too Large'
    415: 'Unsupported Media Type'
    416: 'Requested range not satisfiable'
    417: 'Expectation Failed'
    418: "I'm a teapot"                         # RFC 2324
    420: 'Enhance Your Calm'                    # twitter.com extension
    422: 'Unprocessable Entity'                 # RFC 4918
    423: 'Locked'                               # RFC 4918
    424: 'Failed Dependency'                    # RFC 4918
    425: 'Unordered Collection'                 # RFC 3648
    426: 'Upgrade Required'                     # RFC 2817
    428: 'Precondition Required'                # RFC 6585
    429: 'Too many requests'                    # RFC 6585
    431: 'Request Header Fields Too Large'      # RFC 6585
    444: 'No Response'                          # Nginx extension
    449: 'Retry With'                           # Microsoft IIS extension
    450: 'Blocked by Windows Parental Controls' # Microsoft IIS extension
    499: 'Client Closed Request'                # Nginx extension
    500: 'Internal Server Error'
    501: 'Not Implemented'
    502: 'Bad Gateway'
    503: 'Service Unavailable'
    504: 'Gateway Time-out'
    505: 'HTTP Version not supported'
    506: 'Variant Also Negotiates'              # RFC 2295
    507: 'Insufficient Storage'                 # RFC 4918
    508: 'Loop Detected'                        # RFC 5842
    509: 'Bandwidth Limit Exceeded'             # Apache HTTPD extension
    510: 'Not Extended'                         # RFC 2774
    511: 'Network Authentication Required'      # RFC 6585

  # The list of HTTP methods supported by the WebDAV protocol.
  #
  Carcass.WEBDAV_METHODS = [ 'PROPFIND', 'PROPPATCH', 'MKCOL', 'GET', 'HEAD',
    'POST', 'DELETE', 'PUT', 'COPY', 'MOVE', 'LOCK', 'UNLOCK' ]

  # Default hostname
  #
  Carcass.DEFAULT_HOST = 'localhost'
  
  # Default connection port.
  #
  Carcass.DEFAULT_PORT = 80

  # Default connection protocol.
  #
  Carcass.DEFAULT_PROTOCOL = 'http'

  # Default character encoding of the request body.
  #
  Carcass.DEFAULT_CHARSET = 'UTF-8'

  # The WebDAV XML schema.
  #
  Carcass.WEBDAV_NAMESPACE_URI = 'DAV:'

  # The namespace associated to the Carcass XML schema.
  #
  Carcass.WEBDAV_NAMESPACE = 'D'

  # Max value for the Timeout header.
  #
  Carcass.HEADER_TIMEOUT_MAX = 4100000000

  # Default timeout of asynchronous requests.
  #
  Carcass.DEFAULT_TIMEOUT = 1000

  # The type of the lock for a LOCK request. The only value supported by the
  # current version of the protocol is 'write'.
  #
  Carcass.LockType =
    WRITE: 'write'

  # The scope for a lock request.
  #
  Carcass.Scope =
    EXCLUSIVE: 'exclusive'
    SHARED: 'shared'
  
  # Per-method list of HTTP status code to be considered successful.
  Carcass.RequestSuccessStatus =
    PROPFIND: 207
  
  #############################################################################
  # TEMPLATES
  #############################################################################

  # The list of request body templates.
  #
  Carcass.RequestTemplate = {}
  
  # Mustache template for the generation of a PROPFIND request body.
  #
  Carcass.RequestTemplate.PROPFIND_BODY =
    """
    <?xml version='1.0' encoding='{{encoding}}' ?>
    <propfind xmlns='{{webdavSchema}}'>
    {{#propname}}<propname/>{{/propname}}
    {{^propname}}
      {{#haveProperties}}
        <prop{{#namespaces}} xmlns:{{ns}}='{{schema}}'{{/namespaces}}>
          {{#properties}}<{{#ns}}{{ns}}:{{/ns}}{{name}}/>{{/properties}}
        </prop>
      {{/haveProperties}}
      {{^haveProperties}}<allprop/>{{/haveProperties}}
    {{/propname}}
    </propfind>
    """

  # Mustache template for the generation of a PROPPATCH request body.
  #
  Carcass.RequestTemplate.PROPPATCH_BODY =
    """
    <?xml version="1.0" encoding="{{encoding}}" ?>
    <propertyupdate
      xmlns="{{webdavSchema}}"{{#namespaces}}
      xmlns:{{ns}}="{{schema}}"{{/namespaces}}>
    <set>
      {{#setProperties}}<prop>{{>value}}</prop>{{/setProperties}}
    </set>
    <remove>
      {{#removeProperties}}
        <prop>
          <{{#ns}}{{ns}}:{{/ns}}{{name}}/>
        </prop>
      {{/removeProperties}}
    </remove>
    </propertyupdate>
    """

  # Mustache template for the generation of the value entry of a PROPATCH
  # request body.
  #
  Carcass.RequestTemplate.PROPPATCH_VALUE =
    """
    <{{#ns}}{{ns}}:{{/ns}}{{name}}>
      {{value}}{{#fields}}{{>value}}{{/fields}}
    </{{name}}>
    """

  # Mustache template for the generation of a LOCK request body.
  #
  Carcass.RequestTemplate.LOCK_BODY =
    """
    <?xml version="1.0" encoding="{{encoding}}" ?>
    <lockinfo xmlns="{{webdavSchema}}">
      <lockscope><{{scope}}/></lockscope>
      <locktype><{{type}}/></locktype>
      <owner><href>{{owner}}</href></owner>
    </lockinfo>
    """

  #############################################################################
  # XPATH QUERIES
  #############################################################################

  # The list of XPath queries used to fetch the data returned by the server.
  #
  Carcass.XPathQuery = {}

  # Match the returned resources.
  #
  Carcass.XPathQuery.RESOURCES =
  "/*[local-name() = 'multistatus' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'response' and namespace-uri() = namespace-uri(/*)]"

  # Check if the resource is a collection.
  #
  Carcass.XPathQuery.IS_COLLECTION =
  "boolean(./*[local-name() = 'propstat'
  and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'resourcetype' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'collection' and namespace-uri() = namespace-uri(/*)])"

  # Get the href of a resource.
  #
  Carcass.XPathQuery.RESOURCE_HREF =
  "string(./*[local-name() = 'href' and namespace-uri() = namespace-uri(/*)])"

  # Get the creation time of a resource.
  #
  Carcass.XPathQuery.RESOURCE_CTIME =
  "string(./*[local-name() = 'propstat'
  and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'creationdate' and namespace-uri() = namespace-uri(/*)])"

  # Get the modification time of a resource.
  #
  Carcass.XPathQuery.RESOURCE_MTIME =
  "string(./*[local-name() = 'propstat'
  and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'getlastmodified'
  and namespace-uri() = namespace-uri(/*)])"

  # Get the ETag of a resource.
  #
  Carcass.XPathQuery.RESOURCE_ETAG =
  "string(./*[local-name() = 'propstat'
  and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]
  /*[local-name() = 'getetag' and namespace-uri() = namespace-uri(/*)])"

  # Get the mime type of a resource.
  #
  Carcass.XPathQuery.RESOURCE_MIME_TYPE =
  "string(.//*[local-name() = 'getcontenttype'
  and namespace-uri() = namespace-uri(/*)])"

  # Get the size of a resource.
  #
  Carcass.XPathQuery.RESOURCE_SIZE =
  "number(.//*[local-name() = 'getcontentlength'
  and namespace-uri() = namespace-uri(/*)])"
  
  #############################################################################
  # HANDLERS
  #############################################################################
  
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
            
      # create the namespace resolver from the XML document
      nsResolver = this.responseXML.createNSResolver(
        this.responseXML.documentElement)

      # get the list of resource nodes in the response
      nodes = this.responseXML.evaluate(
        Carcass.XPathQuery.RESOURCES,
        this.responseXML,
        nsResolver,
        XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
        null)

      # create a resource object from each XML resource element and save
      # it into a simple list
      resources = []
      i = 0
      while i < nodes.snapshotLength

        # read the XML element
        node = nodes.snapshotItem(i)

        # create the resource object
        if this.responseXML.evaluate(
          Carcass.XPathQuery.IS_COLLECTION,
          node,
          nsResolver,
          XPathResult.BOOLEAN_TYPE,
          null).booleanValue
              
          currentResource = new Carcass.Collection()
              
        else
              
          currentResource  = new Carcass.Resource()

        # set the resource fields
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
              
        # the mime type node could not exist if the resource mime type is
        # unknown
        currentResource.mimeType = null if currentResource.mimeType is ''

        # only simple resources have the size field
        if not currentResource instanceof Carcass.Collection

          currentResource.size = this.responseXML.evaluate(
            Carcass.XPathQuery.RESOURCE_SIZE,
            node,
            nsResolver,
            XPathResult.NUMBER_TYPE,
            null).numberValue

        resources.push(currentResource)
            
        i += 1
          
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
        resourceDepth = resource.href
                        .replace(/\/$/, '')
                        .split('/')
                        .length
            
        # if the current resource is less deeper than the root
        if resourceDepth < rootDepth
              
          # the current resource is a better candidate for the tree root
          root = resource
          rootDepth = root.href.replace(/\/$/, '').split('/').length

        # remember the current resource
        indexedResources[resource.href] = resource
        unprocessedResources[resource.href] = resource

      # now that have determine the root, consider it as processed,
      # remove it from the list of unprocessed resources and proceed to
      # build the resource tree
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

  #############################################################################
  # CLASSES
  #############################################################################
  
  # An object of this class identifies a WebDAV resource.
  #
  class Carcass.Resource
  
    constructor: ->
  
    # @property [String] The url to the resource.
    #
    href: null
  
    # @property [Date] The resource creation time.
    #
    ctime: null
  
    # @property [Date] The resource creation time.
    #
    mtime: null
  
    # @property [String] The resource mime type.
    #
    mimeType: null
  
    # @property [Carcass.Resource] The resource parent.
    #
    parent: null
  
    # @property [Number] The resource size.
    #
    size: null
  
    # @property [String] The resource ETag.
    #
    etag: null

    # Return a string description of this object, useful when printing the
    # object to the console.
    #
    # @return [String] A string description of this object.
    #
    toString: ->
      return "[object Carcass.Resource]"

  # An object of this class identifies a collection of WebDAV resources.
  #
  class Carcass.Collection extends Carcass.Resource
  
    # @property [Array<Carcass.Resource>]
    # The list of resources contained into this resource.
    #
    members: []

    # Return a string description of this object, useful when printing the
    # object  to the console.
    #
    # @return [String] A string description of this object.
    #
    toString: ->
      return "[object Carcass.Collection]"
    
  #############################################################################
  # HELPERS
  #############################################################################

  # Namespace for utility functions, defined for internal use only.
  #
  # @mixin
  #
  Carcass.utils = {}

  # Read the properties data structure and return the list of namespaces.
  #
  # @param properties [Array] The list of properties to analyze.
  #
  # @return [Array] The list of namespaces and schemas found.
  #
  Carcass.utils.readNamespaces = (properties) ->
    
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
                ns: 'ns' + Object.keys(schemas).length
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
      for own name, schema in schemas
        namespaces.push(schema)
    
    return namespaces
    
  #############################################################################
  # CLIENT
  #############################################################################

  # Creates a new Carcass client.
  #
  class Carcass.Client

    # Construct a new Carcass Client.
    #
    # @param host [String] the host name or IP address of the Carcass share.
    # @param port [Number] TCP port of the host.
    # @param protocol [String] protocol part of URLs.
    # @param user [String] optional user name to use for authentication
    #        purposes.
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
      @xhr = new XMLHttpRequest()
      @xhr.timeout = Carcass.DEFAULT_TIMEOUT
      
      # this request is always asynchronous (the last argument is always true)
      @xhr.open(method, path, true, @user, @password)
      
      return @xhr

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
    
    # Retrieve the contents of a resource.
    #
    # @param path [String] The path to the requested resource.
    # @param handler [Function] The function called when on request completion.
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param handler [Function] The function called when on request
    #        completion.
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param overwrite [Boolean] Whether he destination should be overwritten
    #        if exists.
    # @param handler [Function] The function called when on request completion.
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    
      xhr.send()3403688541
    
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
          namespaces: Carcass.utils.readNamespaces(properties)
        }
      ))
    
      @

    # Set and/or remove properties of a resource.
    #
    # @param path [String] The path to the resource that will be modified.
    # @param setProperties [Array] The properties that will be set on the
    #        resource.
    # @param deleteProperties [Array<Object>] The properties that will be
    #        deleted
    #        from the resource. The array must contain elements of the form
    #        { name: 'property name', schema: 'XML schema url' }. If an element
    #        does not contain the 'name' property, it is ignored. If an element
    #        does not contain the 'schema' property, no schema is used and the
    #        protocol will fall back to the default Carcass namespace.
    # @param lockToken [String] The token for the locked resource.
    # @param handler [Function] The function called when on request completion.
    # @param context [Object] The context in which the handler will be
    #        executed.
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
          namespaces: Carcass.utils.readNamespaces(setProperties)
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
    # @param context [Object] The context in which the handler will be
    #        executed.
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
  
  return Carcass
