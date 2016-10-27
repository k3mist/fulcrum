'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = {}
  Helpers = require("./helpers/_helpers_")

  ###
  The Context class creates a context for the modules. A module may have private contexts and
  contain its own settings outside of the global context.
  ###
  class Fulcrum.Context

    ###
    Optional inheritance of settings from a parent context

    @property {Fulcrum.Context}
    ###
    parentContext: null


    ###
    Mediator helper

    @property {Fulcrum.Helpers.Mediator}
    ###
    mediator: null


    ###
    Settings helper

    @property {Fulcrum.Helpers.Settings}
    ###
    settings: null


    ###
    Constructor

    @param parentContext {Object} Optional inheritance of settings from a parent context
    ###
    constructor: (parentContext) ->
      @parentContext = parentContext
      @mediator = if @parentContext then @parentContext.mediator else new Helpers.Mediator()
      @settings = new Helpers.Settings(@parentContext.settings  if @parentContext)


    ###
    This is the method used to get settings from the context. This will return an object that has
    settings as object properties. Consumers can simply use the settings' property keys
    to retrieve values. For example, context.getSettings().base-server-url will look for a
    setting object defined under the 'base-server-url' property.

    If context is a part of a context hierarchy, the settings object returned will contain
    settings of all parent contexts. Settings from child contexts will override settings from
    parent contexts, if same key exists.

    To improve performance, it is a good practice to store the returned object and reduce the
    number of calls to this method.

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
    gs: ->
      @getSettings.apply @, arguments


    ###
    One can pass an object containing settings as properties in it. If the existing
    settings contain a properties with same key, those will be replaced.

    @method addSettings
    @param newSettings {Object} object containing settings as properties in it
    ###
    addSettings: (newSettings) ->
      @settings.load.apply @settings, arguments


    ###
    This is the method to raise an event in the context. All subscribers in the same context hierarchy
    will be notified. The first parameter is the event name as a string, and the next parameter is the
    event data as an object or function.

    @method publish
    @param event {String} Event name
    @param params {Object/Function} Event data
    ###
    publish: (event, params) ->
      @mediator.publish.apply @mediator, arguments


    ###
    This is the method to raise an event in the context. All subscribers in the same context hierarchy
    will be notified. The first parameter is the event name as a string, and the next parameter is the
    event data as an object or function.

    This method run all events synchronously and should only be needed in testing.

    @method publishSync
    @param event {String} Event name
    @param params {Object/Function} Event data
    ###
    publishSync: (event, params) ->
      @mediator.publishSync.apply @mediator, arguments


    ###
    The method for subscribing to receive events. first parameter is the name of the event you wish
    to receive. Next, is the callback function to invoke when the event has occurred. The callback
    function may have a parameter in case it is interesting to receive the event data as well.

    @method subscribe
    @param event {String} Event name
    @param fn {Object} Callback function
    ###
    subscribe: (event, fn) ->
      @mediator.subscribe.apply @mediator, arguments


    ###
    The method for unsubscribing to events. The only parameter is the saved event subscriber.

    @method unsubscribe
    @param token {Object} The token (saved) subscriber
    ###
    unsubscribe: (token) ->
      @mediator.unsubscribe.apply @mediator, arguments


    ###
    Helper method to allow the viewmodels and views to pubsub without passing in the entire context.

    @method getMediator
    ###
    getMediator: -> @mediator


    ###
    If someone is interested in obtaining the parent context, this method could be used. But it is not a
    good practice to work directly on contexts other than your immediate. Instead use events to communicate.

    @method getParentContext
    @return {Object} parentContext Parent context object
    ###
    getParentContext: -> @parentContext
