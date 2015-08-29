{$, $$, SelectListView, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'
Projects = require './projects'
Project = require './project'

module.exports =
class ProjectsListView extends SelectListView
  possibleFilterKeys: ['title', 'group', 'template']

  activate: ->
    new ProjectListView

  initialize: (serializeState) ->
    super
    @addClass('project-manager')

  serialize: ->

  getFilterKey: ->
    filter = 'title'
    input = @filterEditorView.getText()
    inputArr = input.split(':')

    if inputArr.length > 1 and inputArr[0] in @possibleFilterKeys
      filter = inputArr[0]

    return filter

  getFilterQuery: ->
    input = @filterEditorView.getText()
    inputArr = input.split(':')

    if inputArr.length > 1
      input = inputArr[1]

    return input

  cancelled: ->
    @hide()

  confirmed: (props) ->
    project = new Project(props)
    project.open()
    @cancel()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No projects saved yet'
    else
      super

  toggle: () ->
    if @panel?.isVisible()
      @hide()
    else
      projects = new Projects()
      projects.getAll (projects) =>
        @show(projects)

  hide: ->
    @panel?.hide()

  show: (projects) ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    items = []
    sortBy = atom.config.get('project-manager.sortBy')
    for project in projects
      items.push(project.props)
    if sortBy isnt 'default'
      items = @sortBy(items, sortBy)
    @setItems(items)
    @focusFilterEditor()

  viewForItem: (project) ->
    $$ ->
      @li class: 'two-lines', 'data-project-title': project.title, =>
        @div class: 'primary-line', =>
          @span class: 'project-manager-devmode' if project.devMode
          @div class: "icon #{project.icon}", =>
            @span project.title
            @span class: 'project-manager-list-group', project.group if project.group?

        if atom.config.get('project-manager.showPath')
          for path in project.paths
            @div class: 'secondary-line', =>
              @div class: 'no-icon', path

  sortBy: (arr, key) ->
    arr.sort (a, b) ->
      (a[key] || '\uffff').toUpperCase() > (b[key] || '\uffff').toUpperCase()