module.exports = (grunt) ->

  copyTargets = [
    { expand: true, cwd: 'src', src: ['**', '!**/*.coffee'], dest: 'build' }
  ]
  dirs = ["build/www/lib/" ]
  libs = [
    { cwd: "bower_components/jquery/dist/", dest: "jquery/" }
    { cwd: "bower_components/bootstrap/dist/", dest: "bootstrap/" }
    { cwd: "bower_components/font-awesome/",  dest: "font-awesome/" }
#    { cwd: "bower_components/bootstrap-social/", dest: "bootstrap-social/" }
#    { cwd: "bower_components/react/", dest: "react/" }
#    { cwd: "bower_components/underscore/", dest: "underscore/" }
  ]
  for dir in dirs
    for lib in libs
      copyTargets.push {
        src: "**/*"
        expand: true
        cwd: lib.cwd
        dest: "#{dir}#{lib.dest}"
      }


  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    copy:
      build:
        files: copyTargets
    clean:
      build:
        [ 'build' ]
      bin:
        [ 'bin' ]
    coffee:
      lib:
        files: [
          expand: true
          cwd: 'src'
          src: ['**/*.coffee']
          dest: 'build'
          ext: '.js'
        ]
    watch:
      all:
        files: [
          'Gruntfile.coffee'
          'src/**/*'
          'package.json'
        ]
        tasks: ["run-express"]
        options:
          spawn: false
    shell:
      "debug":
        options:
          stdout: true
        command: 'node-debug build/app.js'
      "run":
        options:
          stdout: true
        command: 'node build/app.js'
        
    notify:
      complete:
        options:
          title: 'Project Compiled',  # optional
          message: 'Project has been compiled', #required
    browserify:
      client:
        src: ["build/client/**/*.js"]
        dest: 'build/www/client.js'
    express:
      dev:
        options:
          script: "./build/app.js"


  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-install-dependencies'
  grunt.loadNpmTasks 'grunt-notify'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-express-server'

  grunt.registerTask 'default', 'Compiles all of the assets and copies the files to the build directory.', [ 'build' ]
  grunt.registerTask 'build', 'Builds the application', [
    'clean:build',
    'coffee',
    'copy',
    'browserify:client'
    'notify:complete'
  ]
  grunt.registerTask 'debug', 'start debug', ['build', "shell:debug"]
  grunt.registerTask 'run', 'start', ['build', "shell:run"]
