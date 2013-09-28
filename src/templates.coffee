# -----------------------------------------------------------------------------
# TEMPLATES
# -----------------------------------------------------------------------------

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
