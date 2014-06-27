'use strict'

module = angular.module 'cybFileBrowser', []
module.directive 'cybFileBrowser', ($filter) ->
  restrict: 'AE'
  templateUrl: 'cyb-file-browser.html'
  scope:
    files             : '='
    allowCreate       : '=?'
    allowRead         : '=?'
    allowUpdate       : '=?'
    allowDelete       : '=?'
    baseUrl           : '=?'
    folderClosedIcon  : '=?'
    folderOpenIcon    : '=?'
    foldoutIcon       : '=?'
    rootTitle         : '=?'
    showRootTitle     : '=?'
    onSelect          : '&?'
    onChangeDirectory : '&?'

  link: (scope, element, attrs) ->
    console.log scope.rootTitle
    scope.currentDir   = ''
    scope.currentFiles = []
    scope.allowCreate      ?= false
    scope.allowRead        ?= false
    scope.allowUpdate      ?= false
    scope.allowDelete      ?= false
    scope.baseUrl          ?= '/'
    scope.folderClosedIcon ?= 'glyphicon glyphicon-folder-close'
    scope.folderOpenIcon   ?= 'glyphicon glyphicon-folder-open'
    scope.foldoutIcon      ?= ''
    if scope.showRootTitle isnt false
      scope.rootTitle ?= 'Root'
    else
      scope.rootTitle = ''

    getDirName = (filename) ->
      name = filename.split '/'
      name.pop()
      name.join '/'

    getBaseName = (filename) ->
      name = filename.split '/'
      # If directory
      if filename.slice(filename.length-1) == '/'
        name = name.slice name.length-2, name.length-1
        "#{name.join '/'}/"
      else
        name.pop()

    scope.processFiles = (files) ->
      listing = {'': []}
      return listing  unless files?

      for filename in files
        dirname = getDirName filename

        file =
          name   : filename
          path   : filename
          isDir  : false
          isOpen : false

        # If directory
        if filename.slice(filename.length-1) == '/'
          listing[ dirname ] = []
          file.name = dirname
          file.isDir = true
          dirname = getDirName dirname

        file.name = file.name.split('/').pop()
        listing[ dirname ].push file

      listing

    scope.filesInDir = (dir) ->
      listing = [[], null, false]  # false instead of null since duplicates are not allowed
      return listing  unless scope.files?
      # Remove trailing '/'
      dir = dir.slice(0, dir.length-1)  if dir.match '\/$'

      dirs = dir.split '/'
      # Add root to beginning if it isn't already there
      dirs.unshift ''  unless dir is ''
      # Add trailing slash to `dir` so we can compare it in the loop below
      dir += '/'
      # Limit to three deepest dirs
      lastDirs = dirs.slice Math.max dirs.length-3, 0

      startIndex = dirs.length - lastDirs.length
      for currentDir, index in lastDirs
        fullDir = dirs.slice(1, index+1+startIndex).join '/'
        # Sort the files and add selection data
        if scope.files[fullDir]?.length
          files       = []
          directories = []
          for file in $filter('naturalSort') scope.files[fullDir], true, 'name'
            if file.isDir
              file.isOpen = dir.indexOf(file.path) == 0
              directories.push file
            else
              files.push file
          listing[index] = directories.concat files
        else
          listing[index] = []

      listing

    scope.select = (path) ->
      dir      = path.split '/'
      filename = dir.pop()  # setting both filename and dir, woo!
      dir      = dir.join '/'

      scope.currentFile     = path
      scope.currentFileName = filename
      scope.currentFileURI  = "#{scope.baseUrl}/#{window.encodeURIComponent path}"

      scope.currentPathSegments = []
      pathSegments = scope.currentFile.split '/'
      for part, index in pathSegments
        if part.length
          scope.currentPathSegments.push {
            name: part
            isDir: index < pathSegments.length-1
          }
      pathSegments = null

      if dir != scope.currentDir
        scope.currentDir   = dir
        scope.currentFiles = scope.filesInDir dir

      if scope.onSelect?
        scope.onSelect fileInfo: filename: filename, path: path, directory: dir, url: scope.currentFileURI, isDirectory: (if filename.length then false else true)


    scope.files = scope.processFiles scope.files
    scope.currentFiles = scope.filesInDir scope.currentDir
