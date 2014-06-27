'use strict'

describe 'Directive: cybFileBrowser', ->

  # load the directive's module
  beforeEach module 'cybFileBrowserApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<cyb-file-browser></cyb-file-browser>'
    element = $compile(element) scope
    expect(element.text()).toBe 'this is the cybFileBrowser directive'
