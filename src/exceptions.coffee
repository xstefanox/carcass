# -----------------------------------------------------------------------------
# EXCEPTIONS
# -----------------------------------------------------------------------------
  
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
