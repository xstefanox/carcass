module.exports = (grunt) ->

  'use strict'

  # project configuration
  grunt.initConfig(

    pkg: grunt.file.readJSON('package.json')

    # development

    clean:
      build: 'build'
      release: 'dist'
      test: [ 'test/test.js', 'test/node.js', 'test/carcass.js' ]
      docs: 'docs'
    
    coffeelint:
      app: 'src/<%= pkg.name %>.coffee'
      test: 'test/**/*.coffee'
      grunt: 'Gruntfile.coffee'

    concat:
      app:
        src: [ 'src/intro.coffee', 'src/exceptions.coffee',
               'src/constants.coffee', 'src/templates.coffee',
               'src/xpath.coffee', 'src/resources.coffee',
               'src/handlers.coffee', 'src/client.coffee' ]
        dest: 'build/<%= pkg.name %>.coffee'
    
    coffee:
      app:
        files:
          'build/<%= pkg.name %>.js': 'build/<%= pkg.name %>.coffee'
        options:
          bare: true
      test:
        files:
          'test/test.js': 'test/test.coffee'
          'test/node.js': 'test/node.coffee'
    
    umd:
      app:
        src: 'build/<%= pkg.name %>.js'
        objectToExport: 'Carcass'
        globalAlias: 'Carcass'
        deps:
          cjs: [ 'mustache', 'xmlhttprequest' ]
          amd: [ 'Mustache', 'XMLHttpRequest' ]
        
    jshint:
      app: 'build/<%= pkg.name %>.js'
      test: 'test/**/*.js'
      
    watch:
      app:
        files: [ 'Gruntfile.coffee', 'src/*.coffee' ]
        tasks: [ 'coffeelint:grunt', 'coffeelint:app', 'coffee:app', 'umd' ]
        options:
          nospawn: false
      test:
        files: [ 'Gruntfile.coffee', 'test/**/*.coffee' ]
        tasks: [ 'coffeelint:grunt', 'coffeelint:test', 'coffee:test' ]
        options:
          nospawn: false

    # test

    copy:
      test:
        src: 'build/<%= pkg.name %>.js'
        dest: 'test/<%= pkg.name %>.js'
    
    qunit:
      all:
        options:
          urls: [ 'http://localhost:8080/test.html' ]

    nodeunit:
      app: 'test/node.js'

    # documentation
    
    docco:
      src: 'src/<%= pkg.name %>.coffee'
      options:
        output: 'docs/src'

    codo:
      src: 'src/<%= pkg.name %>.coffee'
      options:
        output: 'docs/api'
        title: 'Carcass API Documentation'

    # release

    uglify:
      dist:
        files:
          'dist/<%= pkg.name %>-<%= pkg.version %>.min.js':
            'build/<%= pkg.name %>.js'
      options:
        banner: '/* <%= pkg.title || pkg.name %> -
 v<%= pkg.version %> -
 Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author %> -
 <%= pkg.license %> License */'

  )
  
  grunt.util.linefeed = '\r\n'
  
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-jshint')
  grunt.loadNpmTasks('grunt-contrib-qunit')
  grunt.loadNpmTasks('grunt-contrib-nodeunit')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-docco')
  grunt.loadNpmTasks('grunt-umd')
  
  # a server task that creates a WebDAV server serving the test directory
  grunt.registerTask('server', 'Create a WebDAV server', ->

    jsDAV = require('jsDAV/lib/jsdav')
    FSLocksBackend = require('jsDAV/lib/DAV/plugins/locks/fs')

    serverOpts =
      node: "#{__dirname}/test"
      locksBackend: FSLocksBackend.new("#{__dirname}/test")

    serverPort = 8080

    grunt.log.writeln("Starting WebDAV server on port #{serverPort}")

    jsDAV.createServer(serverOpts, serverPort)
  )

  # a task used to generate the API documentation
  grunt.registerTask('codo', 'Generate source documentation', ->
    
    done = this.async()
    
    exec = require('child_process').exec
    config = grunt.config.get(this.name)
    pkg = grunt.config.get('pkg')
    cmd = "codo --name '#{pkg.title || pkg.name}' --title
          '#{config.options.title}' --output-dir '#{config.options.output}'
          '#{config.src}'"
    
    cp = exec(cmd, null, -> done())
    
    cp.stdout.pipe(process.stdout)
    cp.stderr.pipe(process.stdout)
  )
  
  # create a persistent server for development
  grunt.registerTask('dev', [ 'coffeelint:grunt', 'coffeelint:app',
    'concat', 'coffee', 'umd', 'copy', 'server', 'watch' ])
  
  # run all the tests
  grunt.registerTask('test', [ 'coffeelint:test', 'coffee:test',
    'concat', 'coffee', 'umd', 'copy', 'server', 'qunit' ])

  # generate the project documentation
  grunt.registerTask('docs', [ 'docco', 'codo' ])
  
  # default task
  grunt.registerTask('default', [ 'coffeelint:grunt', 'coffeelint:app',
    'concat:app', 'coffee:app', 'umd', 'test', 'uglify', 'docs' ])
