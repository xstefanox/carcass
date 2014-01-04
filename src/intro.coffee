# @author Stefano Varesi

# @license The MIT License

# Required ES5 features: Object.keys

# get a reference to the global namespace
root = exports ? this

# get the XMLHttpRequest object from the global namespace
#XMLHttpRequest = root.XMLHttpRequest

# NPM module for XMLHttpRequest contains the real XMLHttpRequest into a
# property inside the module
if XMLHttpRequest.XMLHttpRequest?
  XMLHttpRequest = XMLHttpRequest.XMLHttpRequest

# declare the main namespace
Carcass = {}