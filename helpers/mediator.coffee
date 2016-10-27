'use strict'

define (require) ->
  _         = require 'underscore'
  Backbone  = require 'backbone'
  Phos      = Helpers: {}
  Logger    = require './logger'

  ###
  An application level event system to mediate between Modules

  A proper and organized event system should adhere to a concise naming system
  to prevent confusion or unexpected behavior.

  Examples:
  - Module:View:Action
  - Module:Component:Action
  - Module:SubModule:View:Action
  - Module:SubModule:Component:Action
  - Module:Route:Action
  - etc...
  ###
  class Phos.Helpers.Mediator

    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Logger()


    ###
    The Marionette application instance provided by the application context

    @private
    @property {Object}
    ###
    app = null


    ###
    The Marionette application instance request handler

    @private
    @property {Object}
    ###
    mediator = null


    ###
    Constructor

    @param options {Object}
    @option options {Object} app The application instance
    ###
    constructor: (options) ->
      mediator = Backbone


    ###
    Publish an event

    @method publish
    @param event
    @param *args
    ###
    publish: ->
      mediator.trigger.apply mediator, arguments


    ###
    Subscribe to an event

    @method subscribe
    @param event
    @param callback
    @param context
    ###
    subscribe: ->
      mediator.on.apply mediator, arguments


    ###
    Unsubscribe from an event

    @method unsubscribe
    @param event
    @param callback
    @param context
    ###
    unsubscribe: ->
      mediator.off.apply mediator, arguments
