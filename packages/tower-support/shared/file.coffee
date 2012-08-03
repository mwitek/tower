# @todo Simplified interface over `fs`, `path`, and `wrench` for dealing with files.
#
# @module
Tower.SupportFile = Tower.File =
  isFile: ->

  isDirectory: ->

  files: ->

  directories: ->

  glob: ->

  stat: ->

  mkdir: (directory, recursive, callback) ->

module.exports = Tower.SupportFile
