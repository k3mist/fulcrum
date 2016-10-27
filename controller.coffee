'use strict'

define (require) ->
  _                   = require 'underscore'
  Backbone            = require 'backbone'
  Backbone.Marionette = require 'backbone.marionette'
  Phos                = {}
  Helpers             = require "./helpers/_helpers_"

  ###
  Abstraction of the Marionette Controller
  ###
  class Phos.Controller extends Backbone.Marionette.Controller

    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Helpers.Logger()


    ###
    The Marionette application instance provided by the application context

    @private
    @property {Object}
    ###
    app = null


    ###
    The context of the application.

    @property {Phos.Context}
    ###
    appContext: null


    ###
    The context of the Module instantiating this Controller

    @property {Phos.Context}
    ###
    modContext: null


    ###
    Regions controlled by this Controller.

    The region property contains a string which is simply the DOM id for the
    container element of the region.

        eg.
        regions:
          moduleRegion: '#region-module'

    @property {Object<String>}
    ###
    regions: null


    ###
    Views of this Controller

        eg.
        views:
          layout: LayoutView
          form: FormView

    @property {Object}
    ###
    views:  null


    ###
    Data for each View on the Controller.

    The viewData object should directly correspond to the same properties
    specified on the views object. The string provided should match a setting
    that was specified in the Module and is accessible through the modContext.

        eg.
        viewData:
          layout: 'someSetting'
          form: 'anotherSetting'

    @property {Object}
    ###
    viewData: null


    ###
    The Controller Router

    @property {Object}
    ###
    router: null


    ###
    The routes and corresponding methods this Controller responds to.
    By setting a route method to "restful", it will automatically generate the
    routes and corresponding method for a restful interface based on that route.

    You must provide the following methods to the controller;
    index, create, show, edit

        eg.
        routes:
          properties: 'restful'

        --->
          /properties => index
          /properties/new => create
          /properties/:id => show
          /properties/:id/edit => edit


    @property {Object}
    ###
    routes: null


    ###
    Constructor

    @param options {Object}
    @option options {Phos.Content} context
    ###
    constructor: (options) ->
      @appContext = options.appContext
      @modContext = options.modContext
      @app = @appContext.getApp()

      # Set module regions
      @app.addRegions(@regions)  if @regions?

      # Initialize Controller Routing
      @router = new Helpers.Router(
        controller: @
        routes: @routes
      )

      # Initialize the Views
      for viewName, View of @views
        if @viewData?
          viewData = @viewData[viewName]
          viewData = @modContext.get(viewData)  if typeof viewData is 'string'
        @views[viewName] = new View(
          appContext: @appContext
          modContext: @modContext
          viewData: viewData
        )  if 'function' is typeof View

      # Initialize the Controller
      super

      # Start Controller mediators
      @startMediating()

      # Start View mediators
      @startViewMediators()

      return @


    ###
    Close the Regions on the Controller

    @method onClose
    ###
    onClose: ->
      for Region of @regions
        for index, View of @views
          if View is @app[Region].currentView
            try
              @app[Region].close()
            catch e
              logger.warn e
          else if not View.isClosed
            View.close()?
      return


    ###
    Start controller mediators. Any mediator event publishing and subscribing
    between the view to the controller and vice versa should happen here.

    @method startMediating
    @placeholder
    ###
    startMediating: ->


    ###
    Start the View mediators

    @method startViewMediators
    ###
    startViewMediators: ->
      @subscribe 'controller:view:closing', =>
        @stopViewMediators()
      for index, view of @views
        view.startMediating() if view.startMediating?
      @


    ###
    Remove the View mediators

    @method stopViewMediators
    ###
    stopViewMediators: ->
      _.each @_events, (callbacks, event) =>
        view = _.first(event.split(':'))
        delete @_events[event]  if @views[view]?


    ###
    Resets a the data on a View. Must be executed prior to the View rendering.

    This implementation will likely change to accomodate more complex data
    queries.

    @method resetViewData
    @param options {Object}
    @option options {String} method The Controller method to run
    @option options {Boolean} close Pass false to prevent closing the view first.
    @option options {String} view The View to close and reset the View Data on
    @option options {String} setting The property for the View Data in the Module Context
    @option options {Object} data The Model or Collection for the View
    ###
    resetViewData: (options) ->
      # Close the view, removing mediators, knockout bindings, and jquery bindings
      @views[options.view].close()
      # Add the new Model or Collection back into the Module Context
      @modContext.set(_.object(["#{options.setting}"], [options.data]))  if options.data?
      # Set the viewData object for the View
      @views[options.view].viewData = @modContext.get(options.setting)
      # Reset the ViewModel for the View
      @views[options.view].setViewModel()
      # Run the Controller method
      @[options.method]()  if options.method?


    ###
    Publish event

    @method publish
    @param eventName {String}
    ###
    publish: (eventName) ->
      @trigger.apply @, arguments


    ###
    Subscribe

    @method subscribe
    @param eventName {String}
    @param callback {Function}
    ###
    subscribe: (eventName, callback) ->
      args = _.toArray(arguments)
      args.unshift @
      @listenTo.apply @, args


    ###
    Unsubscribe

    @method unsubscribe
    @param eventName {String}
    @param callback {Function} Optional
    ###
    unsubscribe: (eventName, callback) ->
      args = _.toArray(arguments)
      args.unshift controller
      @stopListening.apply @, args
