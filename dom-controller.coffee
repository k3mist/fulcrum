'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = {}
  Helpers = require("./helpers/_helpers_")

  ###
  DOM controller is used when it is required to add views to the dom when a
  module is first initialized.
  ###
  class Fulcrum.DomController


    ###
    The parent container for the activation of components

    @property {JQueryElement}
    ###
    scope: null


    ###
    Nodes defined by the modules

    @property {Object}
    ###
    handles: null


    ###
    Constructor

    @param scope {Object} the jQuery element within which the routes get applied
    ###
    constructor: (scope) ->
      @scope = scope
      @handles = {}


    ###
    Add dom nodes

    @method addNodes
    @param newHandles {Object<DOMElement>}
    ###
    addNodes: (newHandles) ->
      _.extend @handles, newHandles


    ###
    Start the DOM controller

    @method start
    ###
    start: ->
      for path of @handles
        if @handles.hasOwnProperty(path)
          @scope.find(path).each (index, element) =>
            # For right now don't allow the dom controller to deactivate components
            # Ask other handlers on this component to deactivate
            #
            # TODO: Is this really needed? leaving commented for now.
            #$(element).trigger "DEACTIVATE_HANDLERS"

            # Bind the current handler for deactivation events
            $(element).bind "DEACTIVATE_HANDLERS", =>
              ###
              @param handler {Fulcrum.Component}
              ###
              ((handler) ->
                handler.deactivate $(element)
              ) @handles[path]


            # Activate the current handler (Component)
            @handles[path].activate $(element)

      @
