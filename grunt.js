/*global module:false */
module.exports = function(grunt) {

  // Project configuration.
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
//    concat: {
//        dist: {
//            src: 'dist/carcass.js',
//            dest: 'dist/carcass.js'
//        },
//        options: {
//            banner: 'config:meta.banner'
//        }
//    },
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

    server: {
      port: 8080,
      base: './test'
    },
//    qunit: {
//      files: ['test/**/*.html']
//    }

    // distribution

    pkg: '<json:package.json>'

  });

  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  grunt.renameTask('test', 'runtest');

  grunt.registerTask('test', 'server watch');

  grunt.registerTask('jam', '', function() {
    var exec = require('child_process').exec;
    
    exec('cat grunt.js', function(error, stdout, stderr) {
      console.log('stdout: ' + stdout);
      console.log('stderr: ' + stderr);
    });
  });

  // Default task.
  grunt.registerTask('default', 'coffee min');

};
