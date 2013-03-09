module.exports = (grunt) ->

  'use strict'

  # project configuration
  grunt.initConfig(

    pkg: grunt.file.readJSON('package.json')

    # development

    clean:
      build: 'build'
      release: 'dist'
      test: [ 'test/data', 'test/test.js' ]
    
    coffeelint:
      app: 'src/carcass.coffee'
      test: 'test/**/*.coffee'
      grunt: 'Gruntfile.coffee'

    coffee:
      app:
        files:
          'build/carcass.js': 'src/carcass.coffee'
        options:
          bare: true
      test:
        files:
          'test/test.js': 'test/test.coffee'
    
    umd:
      src: 'build/carcass.js'
      dependencies:
        commonjs: [ 'mustache', 'xmlhttprequest' ]
        browser: [ 'Mustache', 'XMLHttpRequest' ]
        
    jshint:
      app: 'build/carcass.js'
      test: 'test/test.js'
      
    watch:
      app:
        files: [ 'Gruntfile.coffee', 'src/carcass.coffee' ]
        tasks: [
          'coffeelint:grunt', 'coffeelint:app', 'coffee:app', 'umd', 'uglify'
        ]
        options:
          nospawn: false
      test:
        files: [ 'Gruntfile.coffee', 'test/test.coffee' ]
        tasks: [ 'coffeelint:grunt', 'coffeelint:test' ]
        options:
          nospawn: false

    # test

    qunit:
      all:
        options:
          urls: [ 'http://localhost:8000/test.html' ]
    
    # release

    uglify:
      dist:
        files:
          'dist/carcass.min.js': 'build/carcass.js'
      options:
        banner: '/* <%= pkg.title || pkg.name %> -
 v<%= pkg.version %> -
 Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %> -
 <%= pkg.license %> License */'

  )
  
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-qunit')
  grunt.loadNpmTasks('grunt-coffeelint')

  grunt.registerTask('umd', 'Surrounds the code with the UMD', ->
    
    # prepare the UMD template
    umdTemplate =
      """
(function (root, factory) {
    if (typeof exports === 'object') {
        factory(exports, <commonJsDeps>);
    } else if (typeof define === 'function' && define.amd) {
        define([ 'exports', <amdDeps> ], factory);
    } else {
        factory((root.<moduleName> = {}), <browserDeps>);
    }
}(this, function (<moduleName>, <factoryDeps>) {
<code>
}));
      """
    
    # read the configuration
    config = grunt.config.get(this.name)
    pkg = grunt.config.get('pkg')
    
    # replace the placeholders and write the result
    grunt.file.write('build/carcass.js', umdTemplate
      .replace(/<commonJsDeps>/g,
        (for dep in config.dependencies.commonjs
          "require('#{dep}')").join(', '))
      .replace(/<amdDeps>/g,
        (for dep in config.dependencies.commonjs
          "'#{dep}'").join(', '))
      .replace(/<browserDeps>/g,
        (for dep in config.dependencies.browser
          "root.#{dep}").join(', '))
      .replace(/<factoryDeps>/g, config.dependencies.browser.join(', '))
      .replace(/<moduleName>/g, pkg.title || pkg.name)
      .replace(/<code>/g, grunt.file.read(config.src))
    )
  )
  
  # a server task that creates a WebDAV server serving the test directory
  grunt.registerTask('server', 'Create a WebDAV server', ->

    jsDAV = require('jsDAV/lib/jsdav')
    FSLocksBackend = require('jsDAV/lib/DAV/plugins/locks/fs')

    serverOpts =
      node: "#{__dirname}/test"
      locksBackend: FSLocksBackend.new("#{__dirname}/test")

    serverPort = 8000

    grunt.log.writeln("Starting WebDAV server on port #{serverPort}")

    jsDAV.createServer(serverOpts, serverPort)
  )
  
  grunt.registerTask('test', [ 'coffeelint:test', 'coffee:test',
    'server', 'qunit' ])

  # create a persistent server
  grunt.registerTask('dev', [ 'coffeelint:grunt', 'coffeelint:app',
    'coffee:app', 'umd', 'server', 'watch' ])

  # default task
  grunt.registerTask('default', [ 'coffeelint:grunt', 'coffeelint:app',
    'coffee:app', 'umd', 'test', 'uglify' ])
