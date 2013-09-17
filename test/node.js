(function() {
  var Carcass;

  Carcass = require('build/carcass');

  exports.PROPFIND = function(test) {
    var c;
    c = new Carcass.Client('localhost', 8080);
    return c.PROPFIND('/', 1, null, function(success, statusText, root, resources) {
      test.strictEqual(resources.length, 11, 'Number of resources');
      return test.done();
    });
  };

}).call(this);
