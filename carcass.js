/*jslint browser: true, white: true, sloppy: true */
/*global Carcass: true, Mustache: true, XPathResult: true */

//'use strict';

/**
 * @namespace The Carcass.js library namespace.
 * 
 * Dependencies:
 *  Mustache
 * 
 * Required ES5 features:
 *  Object.keys
 *  Array.forEach
 */
Carcass = {};

////////////////////////////////////////////////////////////////////////////////
// EXCEPTIONS
////////////////////////////////////////////////////////////////////////////////

/**
 * @class Exception thrown when the Mustache library is not loaded..
 * @extends Error
 */
Carcass.MustacheNotFound = function() {
    this.name = 'Carcass.MustacheNotFound';
    this.message = 'Mustache templating library not loaded';
};
Carcass.MustacheNotFound.prototype = new Error();
Carcass.MustacheNotFound.prototype.constructor = Carcass.MustacheNotFound;

/**
 * @class Exception thrown when the browser does not support asynchronous requests..
 * @extends Error
 */
Carcass.UnsupportedBrowser = function() {
    this.name = 'Carcass.UnsupportedBrowser';
    this.message = 'Your browser lacks the features needed to use Carcass.js';
};
Carcass.UnsupportedBrowser.prototype = new Error();
Carcass.UnsupportedBrowser.prototype.constructor = Carcass.UnsupportedBrowser;

/**
 * @class Exception thrown when the value for the Depth header is not valid.
 * @extends Error
 * 
 * @param depth The given depth.
 */
Carcass.InvalidDepth = function(/**Mixed*/ depth) {
    this.name = 'Carcass.InvalidDepth';
    this.message = depth;
};
Carcass.InvalidDepth.prototype = new Error();
Carcass.InvalidDepth.prototype.constructor = Carcass.InvalidDepth;

/**
 * @class Exception thrown when the value for the scope element is not valid.
 * @extends Error
 * 
 * @param scope The given scope.
 */
Carcass.InvalidScope = function(/**String*/ scope) {
    this.name = 'Carcass.InvalidScope';
    this.message = scope;
};
Carcass.InvalidScope.prototype = new Error();
Carcass.InvalidScope.prototype.constructor = Carcass.InvalidScope;

/**
 * @class Exception thrown when the value for the lock type is not valid.
 * @extends Error
 * 
 * @param type The given lock type.
 */
Carcass.InvalidLockType = function(/**String*/ type) {
    this.name = 'Carcass.InvalidLockType';
    this.message = type;
};
Carcass.InvalidLockType.prototype = new Error();
Carcass.InvalidLockType.prototype.constructor = Carcass.InvalidLockType;

/**
 * @class Exception thrown when the response status is not valid for the request method.
 * @extends Error
 * 
 * @param status The response status.
 * @param method The HTTP method of the request.
 */
Carcass.UnexpectedResponseStatus = function(/**Number*/ status, /**String*/ method) {
    this.name = 'Carcass.UnexpectedResponseStatus';
    this.message = status + ' ' + Carcass.HTTP_STATUS_CODES[status] + ", method '" + method + "'";
};
Carcass.UnexpectedResponseStatus.prototype = new Error();
Carcass.UnexpectedResponseStatus.prototype.constructor = Carcass.UnexpectedResponseStatus;

////////////////////////////////////////////////////////////////////////////////
// CONSTANTS
////////////////////////////////////////////////////////////////////////////////

/**
 * @static
 * @description Library name.
 */
Carcass.NAME = 'Carcass.js';

/**
 * @static
 * @description Library version.
 */
Carcass.VERSION = '0.1-alpha';

/**
 * @static
 * @description HTTP status codes reference
 * @see <a href='http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10'>HTTP/1.1 Status code definition</a>
 * 
 * The listed status codes are from HTTP/1.1 specification, except where other RFCs or extensions are specified.
 */
Carcass.HTTP_STATUS_CODES = {
    100: 'Continue',
    101: 'Switching Protocols',
    102: 'Processing',                            // RFC 4918
    200: 'OK',
    201: 'Created',
    202: 'Accepted',
    203: 'None-Authoritive Information',
    204: 'No Content',
    205: 'Reset Content',
    206: 'Partial Content',
    207: 'Multi-Status',                          // RFC 4918
    208: 'Already Reported',                      // RFC 5842
    226: 'IM Used',                               // RFC 3229
    300: 'Multiple Choices',
    301: 'Moved Permanently',
    302: 'Found',
    303: 'See Other',
    304: 'Not Modified',
    305: 'Use Proxy',
    306: 'Switch Proxy',
    307: 'Redirect',
//  308: 'Permanent Redirect',                    // http://tools.ietf.org/html/draft-reschke-http-status-308-07
    400: 'Bad Request',
    401: 'Unauthorized',
    402: 'Payment Required',
    403: 'Forbidden',
    404: 'Not Found',
    405: 'Method Not Allowed',
    406: 'Not Acceptable',
    407: 'Proxy Authentication Required',
    408: 'Request Time-out',
    409: 'Conflict',
    410: 'Gone',
    411: 'Length Required',
    412: 'Precondition Failed',
    413: 'Request Entity Too Large',
    414: 'Request-URI Too Large',
    415: 'Unsupported Media Type',
    416: 'Requested range not satisfiable',
    417: 'Expectation Failed',
    418: "I'm a teapot",                          // RFC 2324
//  420: 'Enhance Your Calm',                     // twitter.com extension
    422: 'Unprocessable Entity',                  // RFC 4918
    423: 'Locked',                                // RFC 4918
    424: 'Failed Dependency',                     // RFC 4918
    425: 'Unordered Collection',                  // RFC 3648
    426: 'Upgrade Required',                      // RFC 2817
//  428: 'Precondition Required',                 // http://tools.ietf.org/html/draft-nottingham-http-new-status-04
//  429: 'Too many requests',                     // http://tools.ietf.org/html/draft-nottingham-http-new-status-04
//  431: 'Request Header Fields Too Large',       // http://tools.ietf.org/html/draft-nottingham-http-new-status-04
//  444: 'No Response',                           // Nginx extension
//  449: 'Retry With',                            // Microsoft IIS extension
//  450: 'Blocked by Windows Parental Controls',  // Microsoft IIS extension
//  499: 'Client Closed Request',                 // Nginx extension
    500: 'Internal Server Error',
    501: 'Not Implemented',
    502: 'Bad Gateway',
    503: 'Service Unavailable',
    504: 'Gateway Time-out',
    505: 'HTTP Version not supported',
    506: 'Variant Also Negotiates',               // RFC 2295
    507: 'Insufficient Storage',                  // RFC 4918
    508: 'Loop Detected',                         // RFC 5842
//  509: 'Bandwidth Limit Exceeded',              // Apache HTTPD extension
    510: 'Not Extended'                           // RFC 2774
//  511: 'Network Authentication Required'        // http://tools.ietf.org/html/draft-nottingham-http-new-status-04
};

//Carcass.WEBDAV_STATUS_CODES = {
//    PROPFIND: {
////        403: 'Infinity-depth requests unsupported by the server',
//        200: 'A property exists and/or its value is successfully returned',
//        401: 'The property cannot be viewed without appropriate authorization',
//        403: 'The property cannot be viewed regardless of authentication',
//        404: 'The property does not exist'
//    },
//    PROPPATCH: {
//        200: 'The property set or change succeeded'
//        
//    }
//};

/**
 * @static
 * @description Default connection port.
 */
Carcass.DEFAULT_PORT = 80;

/**
 * @static
 * @description Default connection protocol.
 */
Carcass.DEFAULT_PROTOCOL = 'http';

/**
 * @static
 * @description Default character encoding of the request body.
 */
Carcass.DEFAULT_CHARSET = 'UTF-8';

/**
 * @static
 * @description The Carcass XML schema.
 */
Carcass.WEBDAV_NAMESPACE_URI = 'DAV:';

/**
 * @static
 * @description The namespace associated to the Carcass XML schema.
 */
Carcass.WEBDAV_NAMESPACE = 'D';

/**
 * @static
 * @description Max value for the Timeout header.
 */
Carcass.HEADER_TIMEOUT_MAX = 4100000000;

/**
 * @static
 * @description Default timeout of asynchronous requests.
 */
Carcass.DEFAULT_TIMEOUT = 1000;

/**
 * @static
 * @description Mustache template for the generation of a PROPFIND request body.
 */
Carcass.PROPFIND_BODY_TPL = '<?xml version="1.0" encoding="{{encoding}}" ?>' +
                           '<propfind xmlns="{{webdavSchema}}">' +
                           '{{#propname}}<propname/>{{/propname}}' +
                           '{{^propname}}' +
                                '{{#haveProperties}}' +
                                    '<prop{{#namespaces}} xmlns:{{ns}}="{{schema}}"{{/namespaces}}>' +
                                        '{{#properties}}<{{#ns}}{{ns}}:{{/ns}}{{name}}/>{{/properties}}' +
                                    '</prop>' +
                                '{{/haveProperties}}' +
                                '{{^haveProperties}}<allprop/>{{/haveProperties}}' +
                           '{{/propname}}' +
                           '</propfind>';

/**
 * @static
 * @description Mustache template for the generation of a PROPPATCH request body.
 */
Carcass.PROPPATCH_BODY_TPL = '<?xml version="1.0" encoding="{{encoding}}" ?>' +
                            '<propertyupdate xmlns="{{webdavSchema}}"{{#namespaces}} xmlns:{{ns}}="{{schema}}"{{/namespaces}}>' +
                            '<set>' +
                                '{{#setProperties}}<prop>{{>value}}</prop>{{/setProperties}}' +
                            '</set>' +
                            '<remove>' +
                                '{{#removeProperties}}<prop><{{#ns}}{{ns}}:{{/ns}}{{name}}/></prop>{{/removeProperties}}' +
                            '</remove>' +
                            '</propertyupdate>';

/**
 * @static
 * @description Mustache template for the generation of the value entry of a PROPATCH request body.
 */
Carcass.PROPPATCH_VALUE_TPL = '<{{#ns}}{{ns}}:{{/ns}}{{name}}>{{value}}{{#fields}}{{>value}}{{/fields}}</{{name}}>';

/**
 * @static
 * @description Mustache template for the generation of a LOCK request body.
 */
Carcass.LOCK_BODY_TPL = '<?xml version="1.0" encoding="{{encoding}}" ?>' +
                       '<lockinfo xmlns="{{webdavSchema}}">' +
                            '<lockscope><{{scope}}/></lockscope>' +
                            '<locktype><{{type}}/></locktype>' +
                            '<owner><href>{{owner}}</href></owner>' +
                       '</lockinfo>';

Carcass.XPATH_RESOURCES = "/*[local-name() = 'multistatus' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'response' and namespace-uri() = namespace-uri(/*)]";
Carcass.XPATH_IS_COLLECTION = "boolean(./*[local-name() = 'propstat' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'resourcetype' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'collection' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_HREF = "string(./*[local-name() = 'href' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_CTIME = "string(./*[local-name() = 'propstat' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'creationdate' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_MTIME = "string(./*[local-name() = 'propstat' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'getlastmodified' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_ETAG = "string(./*[local-name() = 'propstat' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'prop' and namespace-uri() = namespace-uri(/*)]/*[local-name() = 'getetag' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_MIME_TYPE = "string(.//*[local-name() = 'getcontenttype' and namespace-uri() = namespace-uri(/*)])";
Carcass.XPATH_RESOURCE_SIZE = "number(.//*[local-name() = 'getcontentlength' and namespace-uri() = namespace-uri(/*)])";

////////////////////////////////////////////////////////////////////////////////
// CLASSES
////////////////////////////////////////////////////////////////////////////////

Carcass.Resource = function() {
    this.href = null;
    this.ctime = null;
    this.mtime = null;
    this.mimeType = null;
    this.parent = null;
    this.size = null;
    this.etag = null;
};

Carcass.Resource.prototype.toString = function() {
    return "[object Carcass.Resource]";
};

Carcass.Collection = function() {
    Carcass.Collection.parent.constructor.call(this);
    this.children = [];
};
Carcass.Collection.prototype = new Carcass.Resource();
Carcass.Collection.prototype.constructor = Carcass.Collection;
Carcass.Collection.parent = Carcass.Resource.prototype;

Carcass.Collection.prototype.toString = function() {
    return "[object Carcass.Collection]";
};

////////////////////////////////////////////////////////////////////////////////
// HELPERS
////////////////////////////////////////////////////////////////////////////////

/**
 * @namespace Namespace for utility functions, defined for internal use only.
 */
Carcass.utils = {};

/**
 * @function
 * @description Read the properties data structure and return the list of namespaces.
 * 
 * @param properties The list of properties to analyze.
 * @returns The list of namespaces and schemas found.
 */
Carcass.utils.readNamespaces = function(/**Object*/ properties) {
    
    var f,                  // recursive function used internally
        namespaces = [],    // the result value
        schemas = [],       // the list of schemas
        name;               // temporary variable used to loop on object properties
    
    // create a recursive function that walks through the given properties
    f = function(properties, schemas) {
        
        var i,      // the loop counter
            ns,     // the namespace counter
            name;   // the schema loop variable

        // if item is an object, ensure it is contained into an array, to ease our work
        if (!(properties instanceof Array)) {
            properties = [ properties ];
        }

        // create a list of schemas and namespaces that will be used in the generated XML;
        // this list is indexed by schema url
        for (i = 0; i < properties.length; i += 1) {

            // if the 'name' property is empty or undefined
            if (!properties[i].name) {

                // ignore this property
                delete(properties[i]);
            }
            else {

                // if the element schema is defined
                if (properties[i].schema) {

                    // if the schema is not present in the schema list
                    if (!schemas[properties[i].schema]) {

                        // count the schemas
                        ns = 0;
                        for (name in schemas) {
                            if (schemas.hasOwnProperty(name)) {
                                ns += 1;
                            }
                        }

                        // add the schema
                        schemas[properties[i].schema] = {ns: 'ns' + ns, schema: properties[i].schema};
                    }

                    // add the calculated xml namespace to the property element
                    properties[i].ns = schemas[properties[i].schema].ns;

                    // if the element has some nested fields
                    if (properties[i].fields) {

                        // recursively read the nested fields' schemas
                        f(properties[i].fields, schemas);
                    }
                }
                // else don't set any explicit schema and fall back to the default Carcass schema
            }
        }
    };
    
    if (properties) {
        
        // analyze the properties
        f(properties, schemas);

        // remove the indexes from the list and obtain a plain array, which is needed by Mustache
        for (name in schemas) {
            if (schemas.hasOwnProperty(name)) {
                namespaces.push(schemas[name]);
            }
        }
    }
    
    return namespaces;
};

////////////////////////////////////////////////////////////////////////////////
// CLIENT
////////////////////////////////////////////////////////////////////////////////

/**
 * @class Creates a new Carcass client.
 * 
 * @param [host=location.hostname] the host name or IP address of the Carcass share.
 * @param [port=80] TCP port of the host.
 * @param [protocol='http'] protocol part of URLs.
 */
Carcass.Client = function(/**String*/ host, /**Number*/ port, /**String*/ protocol) {

    // check for prerequisites
    if (typeof Mustache === 'undefined') {
        throw new Carcass.MustacheNotFound();
    }
    
    this.host = host || location.hostname;
    this.port = port || location.port || Carcass.DEFAULT_PORT;
    this.protocol = protocol || location.protocol.replace(':', '') || Carcass.DEFAULT_PROTOCOL;
    this.timeout = Carcass.DEFAULT_TIMEOUT;
};
Carcass.Client.prototype = new XMLHttpRequest();
Carcass.Client.prototype.constructor = XMLHttpRequest;
Carcass.Client.parent = XMLHttpRequest.prototype;

Carcass.Client.prototype.toString = function() {
    return "[object Carcass.Client]";
};

/**
 * @function
 * @description Open the connection.
 * 
 * @param method A valid HTTP method.
 * @param path The destination url.
 */
Carcass.Client.prototype.open = function(/**String*/ method, /**String*/ path) {
    
    // this request is always asynchronous (the last argument is always true)
    return Carcass.Client.parent.open.call(this, method, this.protocol + '://' + this.host + ':' + this.port + '/' + path, true);
};

/**
 * @function
 * @description Set the value of the Lock header
 * 
 * @param lockToken The lock token.
 */
Carcass.Client.prototype.setLock = function(/**String*/ lockToken) {
    
    // if a lock token has been given
    if (lockToken) {
        this.setRequestHeader('If', '<' + lockToken + '>');
    }
};

/**
 * @function
 * @description Set the content type of the body
 * 
 * @param charset The charset.
 * @returns The calculated charset. 
 */
Carcass.Client.prototype.setCharset = function(/**String*/ charset) {
    
    // determine the document character set and send the request with the same setting;
    // try the standard property first, then try the MSIE non-standard property and eventually fall back to UTF-8
    charset = charset || document.characterSet || document.charset || Carcass.DEFAULT_CHARSET;
    
    this.setRequestHeader("Content-type", "text/xml; charset=" + charset);
    
    return charset;
};

/**
 * @function
 * @description Retrieve the contents of a resource.
 * 
 * @param path The path to the requested resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.GET = function(/**String*/ path, /**Function*/ handler, /**Object*/ context) {
    
    this.open('GET', path);
    
    this.send();
};

/**
 * @function
 * @description Save the contents of a resource to the server.
 * 
 * @param path The path to the requested resource.
 * @param content The new content of the resource.
 * @param [charset=document.characterSet|Carcass.DEFAULT_CHARSET] The character encoding of the request.
 * @param [lockToken] The token for the locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.PUT = function(/**String*/ path, /**String*/ content, /**String*/ charset, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {
    
    this.open('PUT', path);
    
    this.setCharset(charset);
    
    this.setLock(lockToken);
    
    this.send(content);
};

/**
 * @function
 * @description Remove a resource. It acts recursively if the resource is a collection.
 * 
 * @param path The path to the requested resource.
 * @param [lockToken] The token for the locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.DELETE = function(/**String*/ path, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {
    
    this.open('DELETE', path);
    
    // the Infinity depth is the default for the DELETE method and the only accepted value;
    // it is not required, so we won't send it and fall back to the default
    //request.setRequestHeader("Depth", "Infinity");
    
    this.setLock(lockToken);
    
    this.send();
};

/**
 * @function
 * @description Create a collection.
 * 
 * @param path The path to the requested resource.
 * @param [lockToken] The token for the locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.MKCOL = function(/**String*/ path, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {
    
    this.open('MKCOL', path);
    
    this.setLock(lockToken);
    
    // @TODO: MKCOL may contain a message body
    
    this.send();
};

/**
 * @function
 * @description Create a copy of a resource.
 * 
 * @param source The path to the resource that will be copied.
 * @param destination The destination path of the copy.
 * @param [lockToken] The token for the locked resource.
 * @param [overwrite] Whether he destination should be overwritten if exists.
 * @param [recursive] Whether the copy of a collection should be performed recursively.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.COPY = function(/**String*/ source, /**String*/ destination, /**String*/ lockToken, /**Boolean*/ overwrite, /**Boolean*/ recursive, /**Function*/ handler, /**Object*/ context) {
    
    this.open('COPY', source);
    
    this.setRequestHeader('Destination', destination);
    
    this.setRequestHeader('Overwrite', overwrite ? 'T' : 'F');
    
    this.setRequestHeader('Depth', recursive ? 'Infinity' : '0');
    
    this.setLock(lockToken);
    
    this.send();
};

/**
 * @function
 * @description Move a resource from a location to another.
 * 
 * @param source The path to the resource that will be moved.
 * @param destination The destination path.
 * @param [lockToken] The token for the locked resource.
 * @param [overwrite] Whether he destination should be overwritten if exists.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.MOVE = function(/**String*/ source, /**String*/ destination, /**String*/ lockToken, /**Boolean*/ overwrite, /**Function*/ handler, /**Object*/ context) {
    
    this.open('MOVE', source);
    
    this.setRequestHeader("Destination", destination);
    
    this.setRequestHeader('Overwrite', overwrite ? 'T' : 'F');
    
    this.setLock(lockToken);
    
    this.send();
};

/**
 * @function
 * @description Read the metadata of a resource, optionally including its children.
 * 
 * @param path The path to the resource that will be queried.
 * @param [depth="Infinity"] The depth downto which the resource will be queried, if it is a collecion.
 * @param [properties] The list of properties that will be queried. The array must contain elements of the form
 *        { name: 'property name', schema: 'XML schema url' }. If an element does not contain the 'name' property,
 *        it is ignored. If an element does not contain the 'schema' property, no schema is used and the protocol
 *        will fall back to the default Carcass namespace.
 *        If no property is given, all the resource properties will be fetched.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.PROPFIND = function(/**String*/ path, /**String*/ depth, /**Array**/ properties, /**Function*/ handler, /**Object*/ context) {

    this.open('PROPFIND', path);

    // if a depth has been given
    if (typeof depth !== 'undefined' && depth !== null) {
        
        // fail if the given value is invalid
        if (!((typeof depth === 'string' && depth.toLowerCase() === 'infinity') || depth === 0 || depth === 1)) {

            throw new Carcass.InvalidDepth(depth);
        }
        
        this.setRequestHeader('Depth', depth);
    }

    this.onreadystatechange = function() {
        
        var nsResolver,             // the namespace resolver function
            nodes,                  // the list of resource nodes in the response
            i,                      // loop counter
            r,                      // resource temporary variable
            tmp,                    // temporary variable
            resources,              // the list of resources received from the server
            root,                   // the root of the tree
            indexedResources,       // the list of resources received from the server, indexed by href
            unprocessedResources;   // list of resources to process
        
        if (this.readyState === XMLHttpRequest.DONE) {
            
            if (this.status !== 207) {
                
                throw new Carcass.UnexpectedResponseStatus(this.status, 'PROPFIND');
            }
            
            // create the namespace resolver from the XML document
            nsResolver = this.responseXML.createNSResolver(this.responseXML.documentElement);
            
            // get the list of resources
            nodes = this.responseXML.evaluate(Carcass.XPATH_RESOURCES, this.responseXML, nsResolver, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
            
            // create a resource object from each XML resource element
            resources = [];
            for (i = 0; i < nodes.snapshotLength; i += 1 ) {
                
                // read the XML element
                tmp = nodes.snapshotItem(i);
                
                // create the resource object
                r = this.responseXML.evaluate(Carcass.XPATH_IS_COLLECTION, tmp, nsResolver, XPathResult.BOOLEAN_TYPE, null).booleanValue ? new Carcass.Collection() : new Carcass.Resource();
                
                // set the resource fields
                r.href = this.responseXML.evaluate(Carcass.XPATH_RESOURCE_HREF, tmp, nsResolver, XPathResult.STRING_TYPE, null).stringValue;
                r.ctime = new Date(this.responseXML.evaluate(Carcass.XPATH_RESOURCE_CTIME, tmp, nsResolver, XPathResult.STRING_TYPE, null).stringValue);
                r.mtime = new Date(this.responseXML.evaluate(Carcass.XPATH_RESOURCE_MTIME, tmp, nsResolver, XPathResult.STRING_TYPE, null).stringValue);
                r.etag = this.responseXML.evaluate(Carcass.XPATH_RESOURCE_ETAG, tmp, nsResolver, XPathResult.STRING_TYPE, null).stringValue.replace(/(^")|("$)/g, '');
                
                // the mime type node could not exist if the resource mime type is unknown
                r.mimeType = this.responseXML.evaluate(Carcass.XPATH_RESOURCE_MIME_TYPE, tmp, nsResolver, XPathResult.STRING_TYPE, null).stringValue;
                r.mimeType = r.mimeType === '' ? null : r.mimeType;
                
                // only simple resources have the size field
                if (!(r instanceof Carcass.Collection)) {
                    
                    r.size = this.responseXML.evaluate(Carcass.XPATH_RESOURCE_SIZE, tmp, nsResolver, XPathResult.NUMBER_TYPE, null).numberValue;
                }
                
                resources.push(r);
            }
            
            // find the root
            indexedResources = [];
            unprocessedResources = [];
            resources.forEach(function(resource) {
                
                if ((typeof root === 'undefined')) {
                    
                    root = resource;
                }
                else {
                    if (resource.href.replace(/\/$/, '').split('/').length < root.href.replace(/\/$/, '').split('/').length) {
                        
                        root = resource;
                    }
                }
                
                indexedResources[resource.href] = resource;
                unprocessedResources[resource.href] = resource;
            });
            
            // remove the root from the list of unprocessed resources
            delete(unprocessedResources[root.href]);
            
            // if there are resources to process
            while (Object.keys(unprocessedResources).length > 0) {
                
                for (r in unprocessedResources) {
                    
                    if (unprocessedResources.hasOwnProperty(r)) {
                    
                        // determine the path of the parent resource
                        tmp = unprocessedResources[r].href.replace(/\/$/, '').split('/');
                        tmp.pop();

                        // link this resource with its parent
                        unprocessedResources[r].parent = indexedResources[tmp.join('/') + '/'];
                        unprocessedResources[r].parent.children.push(unprocessedResources[r]);

                        // remove this resource from the list
                        delete(unprocessedResources[r]);
                    }
                }
            }
            
            // if a valid handler has been given
            if (typeof handler !== 'undefined') {

                if (typeof handler !== 'function') {
                    
                    throw new TypeError("Invalid handler for method 'PROPFIND'");
                }
                
                // execute the handler, passing the rrot and the resources returned by the server
                handler.call(context ? context : this, root, resources);
            }
        }
    };
    
    this.send(Mustache.render(Carcass.PROPFIND_BODY_TPL, {
        encoding: this.setCharset(),
        webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
        haveProperties: properties instanceof Array && properties.length,
        properties: properties,
        namespaces: Carcass.utils.readNamespaces(properties)
    }));
};

/**
 * @function
 * @description Set and/or remove properties of a resource.
 * 
 * @param path The path to the resource that will be modified.
 * @param setProperties The properties that will set on the resource.
 * @param [deleteProperties] The properties that will be rmoved from the resource. The array must contain elements of the form
 *        { name: 'property name', schema: 'XML schema url' }. If an element does not contain the 'name' property,
 *        it is ignored. If an element does not contain the 'schema' property, no schema is used and the protocol
 *        will fall back to the default Carcass namespace.
 * @param [lockToken] The token for the locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.PROPPATCH = function(/**String*/ path, /**Object*/ setProperties, /**Object*/ deleteProperties, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {

    this.open('PROPPATCH', path);
    
    this.setLock(lockToken);

    this.send(Mustache.render(Carcass.PROPPATCH_BODY_TPL, {
            encoding: this.setCharset(),
            webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
            setProperties: setProperties,
            deleteProperties: deleteProperties,
            namespaces: Carcass.utils.readNamespaces(setProperties)
        },
        {value: Carcass.PROPPATCH_VALUE_TPL}
    ));
};

/**
 * @function
 * @description Lock a resource.
 * 
 * @param path The resource to lock.
 * @param owner An URL identifying the owner of the lock.
 * @param scope The scope of the lock. Accepted values: 'exclusive', 'shared'.
 * @param type The type of the lock. The only accepted value is 'write'.
 * @param [depth="Infinity"] The depth of the lock. Accepted values: '0', 'Infinity'.
 * @param timeout The timeout in seconds of the lock.
 * @param [lockToken] The token for the locked resource. If given, refreshes an already locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.LOCK = function(/**String*/ path, /**String*/ owner, /**String*/ scope, /**String*/ type, /**String*/ depth, /**Number*/ timeout, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {

    // validate the scope value
    if (scope !== 'exclusive' && scope !== 'shared') {
        
        throw new Carcass.InvalidScope(scope);
    }
    
    // 'write' is the only value accepted by the protocol
    if (type !== 'write') {
        
        throw new Carcass.InvalidLockType(type);
    }
    
    this.open('LOCK', path);
    
    // if a depth has been given
    if (typeof depth !== 'undefined' && depth !== null) {
        
        // fail if the given value is invalid
        if (!((typeof depth === 'string' && depth.toLowerCase() === 'infinity') || depth === 0)) {

            throw new Carcass.InvalidDepth(depth);
        }
        
        this.setRequestHeader('Depth', depth);
    }
    
    if (lockToken) {
        
        this.setLock(lockToken);
        
    } else {
    
        // if no timeout is given, trye to request an infinite timeout or the maximum supported timeout at least
        if (!timeout) {
            
            timeout = "Infinite, Second-" + Carcass.HEADER_TIMEOUT_MAX;
            
        } else {

            timeout = 'Second-' + timeout;
        }
        
        this.setRequestHeader('Timeout', timeout);
        
    }
    
    this.send(Mustache.render(Carcass.LOCK_BODY_TPL, {
            encoding: this.setCharset(),
            webdavSchema: Carcass.WEBDAV_NAMESPACE_URI,
            scope: scope,
            type: type,
            owner: owner
        }
    ));
};

/**
 * @function
 * @description Unlock a resource.
 * 
 * @param path The path to the resource that will be modified.
 * @param lockToken The token for the locked resource.
 * @param [handler] The function called when on request completion.
 * @param [context=this] The context in which the handler will be executed.
 */
Carcass.Client.prototype.UNLOCK = function(/**String*/ path, /**String*/ lockToken, /**Function*/ handler, /**Object*/ context) {

    this.open('UNLOCK', path);
    
    this.setLock(lockToken);
    
    this.send();
};
