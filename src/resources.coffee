# -----------------------------------------------------------------------------
# CLASSES
# -----------------------------------------------------------------------------
  
# An object of this class identifies a WebDAV resource.
#
class Carcass.Resource
  
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
    return '[object Carcass.Resource]'

# An object of this class identifies a collection of WebDAV resources.
#
class Carcass.Collection extends Carcass.Resource
  
  # @property [Array<Carcass.Resource>]
  # The list of resources contained into this resource.
  #
  members: []

  # Return a string description of this object, useful when printing the
  # object to the console.
  #
  # @return [String] A string description of this object.
  #
  toString: ->
    return '[object Carcass.Collection]'
