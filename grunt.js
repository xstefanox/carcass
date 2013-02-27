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
        dest: 'dist',
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
        src: [ '<banner:meta.banner>', 'dist/**/*.js' ],
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    watch: {
      files: '<config:coffeelint.app>',
      tasks: 'coffee min'
    },

    // test

//    qunit: {
//      files: ['test/**/*.html']
//    }

    // distribution

    pkg: '<json:package.json>'

  });

  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  // Default task.
  grunt.registerTask('default', 'coffeelint coffee min');

};
