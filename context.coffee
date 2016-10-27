'use strict'

define (require) ->
  _                   = require 'underscore'
  Backbone            = require 'backbone'
  Backbone.Marionette = require 'backbone.marionette'
  Phos                = {}
  Helpers             = require "./helpers/_helpers_"

  ###
  The Context class creates a context for the modules. A module may have private
  contexts and contain its own settings outside of the global context.
  ###
  class Phos.Context

    ###
    The core of the application instance

    @private
    @property {Object}
    ###
    app = null


    ###
    Optional inheritance of settings from a parent context

    @property {Phos.Context}
    ###
    parentContext: null


    ###
    Application mediator

    @property {Object}
    ###
    mediator: null


    ###
    Settings helper

    @property {Phos.Helpers.Settings}
    ###
    settings: null


    ###
    Constructor

    @param parentContext {Object} Optional inheritance of settings from a parent context
    ###
    constructor: (parentContext) ->
      # Initialize the application. This will only happen the very first time
      # new Context() is called
      app = new Backbone.Marionette.Application()  unless app?

      # Set the parent context
      @parentContext = parentContext

      # Create the mediator for this context
      @mediator = if @parentContext then @parentContext.getMediator() else new Helpers.Mediator(app: app)

      # Create the settings for this context
      @settings = new Helpers.Settings(@parentContext.settings  if @parentContext)


    ###
    Access the application instance

    @method getApp
    @return {Object}
    ###
    getApp: -> app


    ###
    Start the application

    @method startApp()
    @return {Object}
    ###
    startApp: ->
      setTimeout ->
        app.start() unless app.isStarted
      , 0


    ###
    If someone is interested in obtaining the parent context, this method could be used. But it is not a
    good practice to work directly on contexts other than your immediate. Instead use events to communicate.

    @method getParentContext
    @return {Object} parentContext Parent context object
    ###
    getParentContext: -> @parentContext


    ###
    Get the active mediator

    @method getMediator
    @return {Object}
    ###
    getMediator: -> @mediator


    ###
    This is the method used to get settings from the context. This will return an object that has
    settings as object properties. Consumers can simply use the settings' property keys
    to retrieve values. For example, context.getSettings('base-server-url') will look for a
    setting object defined under the 'base-server-url' property.

    If context is a part of a context hierarchy, the settings object returned will contain
    settings of all parent contexts. Settings from child contexts will override settings from
    parent contexts, if same key exists.

    This method provides internal caching from the settings helper so any subsequent calls
    to the same object property will return a cached result.

    @method getSettings
    @return {Object} settings
    ###
    getSettings: ->
      if arguments.length > 0
        @settings.find.apply @settings, arguments
      else
        @settings.items()


    ###
    Alias for getSettings

    @method gs
    @alias
    @return {Object} settings
    ###
    get: -> @getSettings.apply @, arguments


    ###
    One can pass an object containing settings as properties in it. If the existing
    settings contain a properties with same key, those will be replaced.

    @method addSettings
    @param newSettings {Object} object containing settings as properties in it
    ###
    set: (newSettings) ->
      @settings.load.apply @settings, arguments


    ###
    Publish an event

    @method publish
    @param params {Mixed}
    ###
    publish: ->
      @mediator.publish.apply @mediator, arguments


    ###
    Subscribe to an event

    @method subscribe
    @param params {Mixed}
    ###
    subscribe: ->
      @mediator.subscribe.apply @mediator, arguments


    ###
    Unsubscribe from an event

    @method unsubscribe
    @param eventName {String} The event to unsubscribe from
    ###
    unsubscribe: (eventName) ->
      @mediator.unsubscribe.apply @mediator, arguments
