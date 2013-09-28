# -----------------------------------------------------------------------------
# CONSTANTS
# -----------------------------------------------------------------------------
  
# The library name.
#
Carcass.NAME = 'Carcass.js'

# The library version.
#
Carcass.VERSION = '0.2.0'

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
# RFC 3648: Web Distributed Authoring and Versioning (WebDAV) Ordered
#           Collections Protocol
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
