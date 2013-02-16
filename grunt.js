/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      banner: '/* <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' <%= pkg.license %> License */'
    },
    coffeelint: {
      app: 'src/**/*.coffee',
      test: 'test/**/*.coffee'
    },
    coffee: {
      app: {
        src: 'src/**/*.coffee',
        dest: 'lib',
        options: {
          bare: false
        }
      }
    },
    qunit: {
      files: ['test/**/*.html']
    },
    min: {
      dist: {
        src: [ '<banner:meta.banner>', '<config:coffee.app.dest>' ],
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  // Default task.
  grunt.registerTask('default', 'coffeelint coffee min');

};
