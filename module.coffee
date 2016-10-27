'use strict'

define (require) ->
  _             = require 'underscore'
  Phos          = {}
  Phos.Context  = require './context'
  Helpers       = require "./helpers/_helpers_"

  ###
  Abstraction of the Marionette Module with module event helpers
  ###
  class Phos.Module

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
    The name of the Module used by the application instance

    @property {String}
    ###
    moduleName: null


    ###
    Enable or disable the auto start of the Module. Defaults to true.

    @property {Boolean}
    ###
    startWithParent: true


    ###
    The global context of the application

    @property {Phos.Context}
    ###
    appContext: null


    ###
    The context of the module

    @property {Phos.Context}
    ###
    modContext: null


    ###
    Module Dock items. Each module defines its own "dock item(s)" aka navigation
    items for the module.

    Any type of property structure may be used for the dock item. The property
    structure should remain consistent and a Collection with a Model should be
    used to store the items and define the default properties of the dock item.
    eg. [
      {
        label: 'Module Name'
        priority: 1000
        color: 'blue'
        href: '/route'
      }
    ]

    @property {Array}
    ###
    moduleDock: null


    ###
    Sub Modules of this Module

    @property {Array<Phos.Module>}
    ###
    modules: null


    ###
    The Controller functioning on this Module

    @property {Object}
    ###
    Controller: null


    ###
    Constructor

    @param options {Object}
    @option options {Phos.Context} context The context of the module
    @option options {Boolean} autoStart Enable or disable auto starting the Module
    ###
    constructor: (options) ->
      if not options.appContext?
        return logger.error @constructor.name, 'Please provide the application context.'
      else
        @appContext = options.appContext
        @modContext = new Phos.Context(options.modContext  if options.modContext?)
        app = @appContext.getApp()  unless app?

      # Set the Module Name
      unless @moduleName?
        return logger.error @constructor.name, 'Please provide a Module Name.'

      # Create the Module
      self = @
      app.module(@moduleName, -> _.extend(@, self))


    ###
    The before start method is an event that is triggered right before the Module
    is started. Initialize the Module Controller here

    In addition you can add initializers through the Module addInitializer
    method.

    @method onBeforeStart
    ###
    onBeforeStart: ->
      if typeof @Controller is 'function'
        @Controller = new @Controller(
          appContext: @appContext
          modContext: @modContext
        )
      else if @Controller? and @Controller.initialize?
        @Controller.initialize()


    ###
    The on start method is an event that is triggered after the Module has
    started. We start sub modules here so we are sure the parent module has
    initialized and setup any views or data that may be required by a sub
    module.

    @method onStart
    ###
    onStart: ->
      # Create the sub modules
      _.each @modules, (Module, i) =>
        new Module(
          appContext: @appContext
          modContext: @modContext
        )  if typeof Module is 'function'

      # Send out an event to add the Dock items for the Module
      @appContext.publish('Core:Module:Dock:Add', @moduleDock)  if @moduleDock?


    ###
    The before stop method is an event that is triggered right before the Module
    is stopped. Peform any pre-teardown functionality here that is not already
    handled by Marionette. For example, a confirmation dialog if the user really
    wants to close the module.

    @placeholder
    @method onBeforeStop
    ###
    onBeforeStop: ->


    ###
    The after stop method is an event that is triggered after the Module is
    stopped. Peform any additional teardown functionality that needs to take place
    here.

    In addition you can add finalizers through the Module addFinalizer
    method.

    @placeholder
    @method onAfterStop
    ###
    onStop: ->
      # Send out an event to remove the Dock items for the Module
      @appContext.publish('Core:Module:Dock:Remove', @moduleDock)  if @moduleDock?
      # Close the controller
      @Controller.close?()
