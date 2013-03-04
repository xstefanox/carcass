/*jslint white: true */
/*global module:false */

module.exports = function(grunt) {

  'use strict';

  // project configuration
  grunt.initConfig({

    meta: {
      banner:
        '/* <%= pkg.title || pkg.name %> - ' +
        'v<%= pkg.version %> - ' +
        'Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %> - ' +
        '<%= pkg.license %> License */'
    },

    // development

    coffeelint: {
      app: 'src/**/*.coffee',
      test: 'test/**/*.coffee'
    },
    coffee: {
      app: {
        src: 'src/**/*.coffee',
        dest: 'build',
        options: {
          bare: false
        }
      }
    },
    min: {
      dist: {
        src: [ '<banner:meta.banner>', 'build/**/*.js' ],
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    watch: {
      files: '<config:coffeelint.app>',
      tasks: /*coffeelint*/ 'coffee min'
    },

    // test

    qunit: {
      files: ['test/**/*.html']
    },

    // distribution

    pkg: '<json:package.json>'

  });

  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  // a server task that creates a WebDAV server serving the test directory
  grunt.registerTask('server', 'Create a WebDAV server', function() {

    var jsDAV = require('jsDAV/lib/jsdav');
    var FSLocksBackend = require('jsDAV/lib/DAV/plugins/locks/fs');
    var temp = require('temp');

    var serverOpts = {
      node: ".",
      locksBackend: new FSLocksBackend(".")
    };

    var serverPort = 8000;

    grunt.log.writeln('Starting WebDAV server on port ' + serverPort);

    jsDAV.createServer(serverOpts, serverPort);

  });

  grunt.registerTask('test', 'server qunit');

  // create a persistent server
  grunt.renameTask('watch', 'runwatch');
  grunt.registerTask('watch', 'server runwatch');

  // Default task.
  grunt.registerTask('default', 'coffee min');

};
