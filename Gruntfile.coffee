
module.exports = (grunt) ->

  # Load npm tasks
  #-----------------------------------------------
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # Config
  #-----------------------------------------------
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    banner:
      """
      /*!
       * <%= pkg.title || pkg.name %> - v<%= pkg.version %> (<%= grunt.template.today("yyyy-mm-dd") %>)
       *
       * @author <%= pkg.author %>
       * @url <%= pkg.homepage %>
       * @copyright <%= grunt.template.today("yyyy") %> <%= pkg.author %>
       * @license <%= pkg.license %>
       */

      """

    watch:
      coffee:
        files: ['src/*.coffee', 'spec/scripts/*.coffee']
        tasks: ['coffee', 'notifydone']

      compass:
        files: ['src/*.scss']
        tasks: ['compass:dev']

      dev:
        files: ['dist/*.js', 'dist/*.css', 'example/index.html']
        tasks: ['reload']

    coffee:
      coffee:
        expand: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'dist'
        ext: '.js'

    compass:
      options:
        config: 'src/config.rb'
        sassDir: 'src/'
        cssDir: 'dist/'
        imagesDir: 'dist/images'
        relativeAssets: true

      dev:
        options:
          outputStyle: 'expanded'
          noLineComments: false

      prod:
        options:
          # outputStyle: 'compressed'
          outputStyle: 'expanded'
          noLineComments: true

    concat:
      dist:
        src: 'dist/minimalSharer.js'
        dest: 'dist/minimalSharer.js'
        options:
          stripBanners: true
          banner: '<%= banner %>'

    uglify:
      options:
        preserveComments: 'some'

      dist:
        src: 'dist/minimalSharer.js'
        dest: 'dist/minimalSharer.min.js'

    copy:
      dist:
        src: 'components/jquery/jquery.min.js'
        dest: 'dist/jquery.min.js'

  # Tasks
  #-----------------------------------------------
  grunt.registerTask 'default', ['dev']

  grunt.registerTask 'dev', [
    'coffee'
    'compass:dev'
    'notifydone'
  ]
  grunt.registerTask 'prod', [
    'coffee'
    'compass:prod'
    'concat'
    'uglify'
    'copy'
    'notifydone'
  ]

  grunt.registerTask 'notifydone', 'done!', ->
    growlnotify 'All tasks done', title: 'Grunt Done', name: 'Grunt'

  grunt.registerTask 'reload', 'reload', ->
    require('child_process').exec 'osascript -e \'tell application \"Google Chrome\" to tell the active tab of its first window to reload\''
    growlnotify 'Reloaded', title: 'Chrome', name: 'Grunt'


  # Notification
  #-----------------------------------------------
  hooker = require 'hooker'

  ['warn', 'fatal'].forEach (level) ->
    hooker.hook grunt.fail, level, (message) ->
      level = level.charAt(0).toUpperCase() + level.substr 1
      growlnotify message, title: "Grunt #{level}", name: 'Grunt'

  hooker.hook grunt.log, 'write', (message) ->
    message = grunt.log.uncolor message

    if message.indexOf('>> Error: ') >= 0
      growlnotify message.substr(10), title: 'Grunt Error', name: 'Grunt', sticky: true


#=== Growl
#==============================================================================================
exec = require('child_process').exec

escapeshellarg = (str) ->
  str = JSON.stringify str
  str = str.replace /\\n/g, '\n'

growlnotify = (message, option = {}) ->
  args = ['growlnotify']

  if message
    args.push '-m', escapeshellarg message

  if option.sticky
    args.push '-s'

  if option.name
    args.push '-n', escapeshellarg option.name

  if option.title
    args.push '-t', escapeshellarg option.title

  exec args.join ' '
