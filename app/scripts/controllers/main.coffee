'use strict'

angular.module('cybFileBrowserApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
    $scope.listOfFiles = [
      'first'
      'second'
      'directory/'
      'directory/sub1'
      'directory/sub2'
      'directory/subDir/'
      'directory/subDir/File1'
    ]
    $scope.fileSelected = (info) ->
      console.log info
