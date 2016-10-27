'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')
  require('koBinding')

  Fulcrum = {}

  ###
  ViewModel is used to create Knockout bindings in native javascript instead of
  the bindings sitting directly in the markup. This provides a clear scope of
  the DOM bindings on the ViewModel and allows for more complex UI interaction.
  ###
  class Fulcrum.ViewModel


    ###
    The current instance of the ViewModel

    @property {Object}
    ###
    instance: null


    ###
    Mediator helper

    @property {Fulcrum.Helpers.Mediator}
    ###
    mediator: null


    ###
    The DOM scope of the ViewModel

    @property {HTMLElement}
    ###
    scope: null


    ###
    The DOM id of the container for the ViewModel

    @property {Fulcrum.Helpers.Mediator}
    ###
    viewId: null


    ###
    The bindings of the ViewModel

    @property {Object}
    ###
    bindings: {}


    ###
    ViewModel initialized

    @property {Boolean}
    ###
    initialized: false


    ###
    Constructor

    @param json {Object} The data to be inherited by the ViewModel
    ###
    constructor: (json) ->
      json = {}  if typeof json isnt 'object' or not json
      @[prop] = json[prop]  for prop of json
      @bindings = {}


    ###
    Creates a binding context in javascript for Knockout

    @method addBindings
    @param rootSelector {String} The root DOM id or class the bindings will be added to
    @param conventions {Object} The binding conventions defined in the component view model
    @return {Object}
    ###
    addBindings: (rootSelector, conventions) ->
      # Add the context of the ViewModel to the arguments
      args = _.toArray arguments
      args.push @
      # Add the bindings to Knockout
      conventions = ko.bindingConventions.conventions.apply @, args
      # Add the instance of bindings for the ViewModel
      @instance = ko.bindingConventions._activeInstance
      conventions


    ###
    Removes the bindings from the view model

    @method removeBindings
    ###
    removeBindings: ->
      if @instance?
        $(@scope).find('*').remove()  if @scope?
        @instance.removeConventions(@)


    ###
    Remove a single nodes' binding

    @method removeBinding
    @param node {String} The #id or .class of the node
    @param root {String} The root selector of the node
    ###
    removeBinding: (node, root) ->
      if @instance?
        @instance.conventions[node] = ((bindings, root) =>
          _.reject bindings, (binding) =>
            if root? and root is binding.rootSelector and binding.context is @
              $(@scope).find(root).find(node).remove()
              true
            else if not root? and binding.context is @
              $(@scope).find(node).remove()
              true
            else
              false
        )(_.find(@instance.conventions, (bindings, selector) -> node is selector), root)

        delete @instance.conventions[node]  if @instance.conventions[node].length is 0


    ###
    Get the bindings of a node

    @method getBindings
    @param node {String}
    @return {Object}
    ###
    getBindings: (node) -> @instance.getBindings($(node).get(0), @)  if @instance?


    ###
    Apply the Knockout bindings.

    @method bind
    @return {Fulcrum.ViewModel}
    ###
    bind: ->
      return @  if @initialized
      # Add the bindings
      _.each @bindings, (bindings, rootSelector) => @addBindings rootSelector, bindings
      @initialized = true
      @
