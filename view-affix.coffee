'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = {}

  ###
  ViewAffix is used to bind jquery and respond to mediated events that would
  require jquery to perform an action on the DOM.
  ###
  class Fulcrum.ViewAffix


    ###
    The DOM scope of the ViewAffix

    @property {JQueryElement}
    ###
    scope: null


    ###
    The mediator of the ViewAffix

    @property {Fulcrum.Helpers.Mediator}
    ###
    mediator: null


    ###
    ViewAffix initialized

    @property {Boolean}
    ###
    initialized: false


    ###
    Constructor

    @param json {Object} The data or functions for the view to inherit
    ###
    constructor: (json) ->
      json = {}  if typeof json isnt 'object' or not json
      @[prop] = json[prop]  for prop of json


    ###
    Apply the JQuery bindings.

    @method bind
    ###
    bind: ->
      return @  if @initialized
      # BINDING CODE
      @initialized = true
      @
