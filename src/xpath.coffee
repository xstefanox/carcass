# -----------------------------------------------------------------------------
# XPATH QUERIES
# -----------------------------------------------------------------------------

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

# A wrapper around the browser XPathResolver, created to ease XPath queries.
#
class Carcass.XPathResolver
  
  xmlDocument: null
  nsResolver: null
  evaluator: null
  
  constructor: (@xmlDocument) ->

    @evaluator = new XPathEvaluator()
    
    if xmlDocument.createNSResolver?
      
      @nsResolver = xmlDocument.createNSResolver(xmlDocument.documentElement)

  getNodeList: (xpath) ->
    
    @evaluator.evaluate(
      xpath,
      @xmlDocument,
      @nsResolver,
      XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
      null)

  getBoolean: (xpath) ->
    
    @evaluator.evaluate(
      xpath,
      @xmlDocument,
      @nsResolver,
      XPathResult.BOOLEAN_TYPE,
      null).booleanValue

  getString: (xpath) ->
    
    @evaluator.evaluate(
      xpath,
      @xmlDocument,
      @nsResolver,
      XPathResult.STRING_TYPE,
      null).stringValue

  getNumber: (xpath) ->
    
    @evaluator.evaluate(
      xpath,
      @xmlDocument,
      @nsResolver,
      XPathResult.NUMBER_TYPE,
      null).numberValue

  # Return a string description of this object, useful when printing the
  # object to the console.
  #
  # @return [String] A string description of this object.
  #
  toString: ->
    return '[object Carcass.XPathResolver]'
