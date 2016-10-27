'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')

  Fulcrum = {}
  Fulcrum.UrlController = require('./url-controller')
  Fulcrum.DomController = require('./dom-controller')
  Fulcrum.ViewTemplate = require('./view-template')
  Helpers = require("./helpers/_helpers_")

  ###
  The Component class provides a simple interface to initialize an interactive view.
  An extended component may contain the parent element in which the component
  resides. In addition the node or route in which the component responds to. It
  has its own context, settings, template, view model, and view affix.

  If a route is provided on the extended Component the route will take presedence
  over the node and only respond to the route. If a container is not specified the
  Component will default to the body of the document.
  ###
  class Fulcrum.Component

    ###
    Component settings that are allowed to be superseded during initialization.

    @private
    @property {Array}
    ###
    _allowed = [
      'container'
      'node'
      'route'
      'context'
      'settings'
      'template'
      'viewModel'
      'viewAffix'
    ]


    ###
    Controls the activation status of the component.

    @property {Function<Boolean>}
    ###
    active: ko.observable()


    ###
    Parent container to affix the component.

    @property {String}
    ###
    container: null


    ###
    DOM node to attach the component

    @property {String}
    ###
    node: null


    ###
    Route of the component

    @property {String}
    ###
    route: null


    ###
    The Controller of the Component

    @property {Fulcrum.DomController / Fulcrum.UrlController}
    ###
    controller: null


    ###
    Context of the component

    @property {Fulcrum.Context}
    ###
    context: null


    ###
    Settings of the component

    @property {Object}
    ###
    settings: null


    ###
    Template markup of the component

    @property {String}
    ###
    template: null


    ###
    View Template

    @property {Fulcrum.ViewTemplate}
    ###
    viewTemplate: null


    ###
    View Model of the component

    @property {Fulcrum.ViewModel}
    ###
    viewModel: null


    ###
    View Affix of the component

    @property {Fulcrum.ViewAffix}
    ###
    viewAffix: null


    ###
    Parent element assigned on component activation

    @property {JQueryElement}
    ###
    parent: null


    ###
    Options provided to the activate method when it is first activated by the
    url or dom controller.

    @property {Object}
    ###
    activationOptions: null


    ###
    Initialize the Component

    @param options {Object}
    @option options {Fulcrum.Context} context Context of the component
    @option options {String} template Template markup of the component
    @option options {Fulcrum.ViewModel} viewModel The View Model for the component
    @option options {Fulcrum.ViewAffix} viewAffix The View Affix for the component
    @option options {String} container Parent container to affix the component
    @option options {String} node DOM node to attach the component
    @option options {String} route Route of the component to which it will respond.
    @option options {Object} settings Settings of the component
    ###
    constructor: (options) ->
      # Set the initial component options
      (@[option] = options[option]  if option in _allowed)  for option of options

      # Set the activation status of the component
      @active = ko.observable false

      # Default to the body if the container was not provided
      @container = 'body'  unless @container?

      # Start the controller
      @startController()


    ###
    Start the Controller. If no node or route is specified the component will
    attach itself to the body as a DOM node without any routing. If a route is
    specified respond to the route only.

    @method startController
    @return {Fulcrum.DomController / Fulcrum.UrlController}
    ###
    startController: ->
      # Only create a new controller if the component is not active and the
      # controller has not been set. The controller check may be removed in the
      # future.
      if not @active() and not @controller?

        # Url controller
        if @route?
          @controller = new Fulcrum.UrlController $(@container)
          @controller.addRoutes _.object([@route], [@])
        # Dom controller
        else
          @controller = new Fulcrum.DomController $(@container)
          @controller.addNodes _.object([@node], [@])

        @controller.start()

      @controller


    ###
    Activate the component.

    @method activate
    @param parent {JQueryElement} The parent container
    @param options {Object}
    @option options {Object} settings Additional settings for view model and
      view affix that are only applied on component activation
    ###
    activate: (parent, options) ->
      # Set the parent container for the component. We just grab the actual
      # DOM element from the JQuery object so when the view template is removed
      # we do not also lose the parent container
      @parent = parent.get(0)  if not @active() and not @parent?

      # Start the controller on reactivation
      @startController()

      # Create default options if none provided.
      unless @activationOptions?
        options = {}  unless options?
        options.settings = {}  unless options.settings?
        @activationOptions = _.extend options.settings, @settings  if @settings?

      # Create the ViewTemplate, ViewModel, and ViewAffix
      if @template? and not @active()
        @viewTemplate = new Fulcrum.ViewTemplate $(@parent), @template, @context.gs('locale')?.locale()

        # Create the View Model
        if typeof @viewModel is 'function'
          @viewModel = new @viewModel(
            _.extend
              viewId: @viewTemplate.getViewId()
              mediator: @context.getMediator()
              scope: @viewTemplate.getDomElement()
            ,
              @activationOptions
          )

        # Bind the Knockout bindings
        if @viewModel? and not @viewModel.initialized
          @viewModel.bind()

        # Apply the Knockout Bindings
        if @viewModel? and typeof @viewModel is 'object'
          ko.applyBindings @viewModel, @viewTemplate.getDomElement()

        # Create the View Affix
        if typeof @viewAffix is 'function'
          @viewAffix = new @viewAffix(
            _.extend
              scope: @viewTemplate.getJQueryElement()
              mediator: @context.getMediator()
            ,
              @activationOptions
          )

        # Bind the JQuery Bindings
        if @viewAffix? and not @viewAffix.initialized
          @viewAffix.bind()

      # Component is active
      @active true


    ###
    Deactivate the component. Will remove the inserted view template and destroy
    any knockout view bindings.

    @method deactivate
    ###
    deactivate: ->
      # Set the component status to inactive
      @active false

      # Kill the route if the component has a url controller
#      if @route? and @controller?
#        @controller.removeRoute @route

      # Remove the controller from memory
#      @controller = null

      # Remove the ViewModel bindings
      if @viewModel? and typeof @viewModel.initialized isnt 'undefined'
        @viewModel.removeBindings()
        #@viewModel.initialized = false

      # Allow the ViewAffix JQuery bindings to be initialized again
      if @viewAffix? and typeof @viewAffix.initialized isnt 'undefined'
        @viewAffix.initialized = false

      # Remove the ViewTemplate (will also remove jquery bindings)
      if @viewTemplate?
        @viewTemplate.remove()
        @viewTemplate = null
