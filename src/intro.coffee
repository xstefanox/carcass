# @author Stefano Varesi

# @license The MIT License

# Required ES5 features: Object.keys

# NPM module for XMLHttpRequest contains the real XMLHttpRequest into a
# property inside the module
if XMLHttpRequest.XMLHttpRequest?
  XMLHttpRequest = XMLHttpRequest.XMLHttpRequest
