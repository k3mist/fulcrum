'use strict'

define (require) ->
  _         = require 'underscore'
  Backbone  = require 'backbone'
  ko        = require 'knockout'
  kb        = require 'knockback'
  koBinding = require 'koBinding'
  Phos      = {}
  Helpers   = require "./helpers/_helpers_"

  ###
  An abstraction of the Marionette ItemView and Layout View

  For more detailed information visit:
  https://github.com/marionettejs/backbone.marionette/blob/master/docs/marionette.view.md
  ###
  class Phos.View

    ###
    Allowed view types

    @private
    @property {Array}
    ###
    viewTypes = [
      'ItemView'
      'Layout'
    ]


    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Helpers.Logger()


    ###
    The type of view to render from Marionette
    Allowed View types:
      ItemView
      Layout

    @property {String}
    ###
    viewType: null


    ###
    Default tag container for the view

    @property {String}
    ###
    tagName: 'span'


    ###
    The stylesheet for the view

    @property {String}
    ###
    style: null


    ###
    The DOM ID of the template container

    @property {String}
    ###
    template: null


    ###
    The Model for the View

    @property {Phos.Model}
    ###
    model: null


    ###
    The Collection for the View

    @property {Phos.Collection}
    ###
    collection: null


    ###
    The Knockback ViewModel for this View

    @property {Knockback.ViewModel}
    ###
    ViewModel: null


    ###
    The Knockout binding conventions for this View

    @property {Object}
    ###
    koBindings: null


    ###
    The jQuery bindings for this View

    @property {Object}
    ###
    jqBindings: null


    ###
    The context of the application.

    @property {Phos.Context}
    ###
    appContext: null


    ###
    The context of the Module via the Controller for this View

    @property {Phos.Context}
    ###
    modContext: null


    ###
    Constructor

    @param options {Object}
    @option options {String} viewType The type of View to create.
    ###
    constructor: (options) ->
      (@[option] = options[option]) for option of options

      # Check provided view type is valid
      if not @viewType in viewTypes
        return logger.error @constructor.name, 'Only ItemView and Layout are permitted as a ViewType.'
      else
        # Default koBindings to an empty object
        @koBindings = {}

      # Prepend the stylesheet
      if @style? and @template?
        @template = "<span>#{Helpers.HTML.scopedCSS(@template, @style).html()}</span>"
      # Default to body if no template
      else if @style?
        @template = "<span>#{Helpers.HTML.scopedCSS('body', @style).html()}</span>"

      # Create the Marionette View
      View = Backbone.Marionette[@viewType].extend(@)

      # Initialize the View and pass the ko view helper as an option
      _.extend @, new View(
        ko: => @ko()
        parent: => @
      )


    ###
    Set the ViewModel on the View

    @method setViewModel
    ###
    setViewModel: ->
      @ViewModel = (=>
        if @viewData? and _.isArray(@viewData.models)
          @collection = @viewData
          kb.collectionObservable(@collection)
        else if @viewData? and typeof @viewData is 'object'
          @model = @viewData
          kb.viewModel(@model)
        else
          null
      )()


    ###
    Start view mediators. Any mediator event publishing and subscribing
    between the view to the controller and vice versa should happen here.

    @method startMediating
    @placeholder
    ###
    startMediating: ->


    ###
    Perform any actions on the View that need to take place prior to the View
    rendering.

    @method onBeforeRender
    @placeholder
    ###
    onBeforeRender: ->
      # Create the ViewModel and set the Collection or Model on the View
      @options.parent().setViewModel()


    ###
    Perform any actions on the View after it has been rendered into the DOM.

    @method onRender
    @placeholder
    ###
    onRender: ->
      applyBindings = =>
        # Create the Knockout bindings conventions.
        @setBindings()  if not @options.ko().getBindings()?
        # Apply the bindings.
        try
          ko.applyBindings(@, @el)  if _.size(@options.parent().koBindings) > 0
        catch e
          logger.error e.stack, e
        # Affix jQuery bindings.
        @options.parent().jqueryBindings()?() unless @jqBindings?

      # Let the browser do its thing before bindings are applied.
      setTimeout =>
        try
          # Affix Knockout bindings
          @options.parent().affixBindings() if _.size(@options.parent().koBindings) is 0

          # Try to apply the ko bindings, should always work first time.
          applyBindings()

        # If applying the bindings failed its likely the Controller method for the
        # matched route was matched without the View closing or the View was not
        # closed before it was inserted into the DOM again.  Remove the bindings,
        # clean the node, and try again.
        catch e
          @options.ko().removeBindings()
          applyBindings()
          logger.error e.stack, e
      , 0

      # Polyfills
      if @options.parent().appContext.get 'polyfill' # ie/opera
        setTimeout =>
          @$el.updatePolyfill()
          @$el.find('input, textarea').placeholder()
        , 100


    ###
    The event method that triggers prior the view closing. Return false in this
    event method to prevent the View from closing.

    @method onBeforeClose
    @placeholder
    ###
    onBeforeClose: -> true


    ###
    The close event method for the View. Perform any tear-down functionality here.
    This will permanently destroy the View.

    @method onClose
    @placeholder
    ###
    onClose: ->
      @options.parent().publish 'controller:view:closing', @
      @options.parent().stopListening @
      @options.parent().ViewModel.destroy()  if @options.parent().ViewModel?
      @options.ko().removeBindings()
      @options.parent().jqBindings = null
      @$el.remove()


    ###
    Handles any actions that need to be taken on the View  when the DOM is refreshed.

    @method onDomRefresh
    @placeholder
    ###
    onDomRefresh: ->


    ###
    Affix the Knockout binding conventions to the View

    @method affixBindings
    @placeholder
    ###
    affixBindings: -> @koBindings = {}


    ###
    Affix the jQuery bindings to the View

    @method affixBindings
    @placeholder
    ###
    jqueryBindings: -> @jqBindings = null


    ###
    Create the Knockout bindings conventions.

    @method setBindings
    @return {Fulcrum.ViewModel}
    ###
    setBindings: ->
      viewko = @ko()
      for rootSelector, bindings of @koBindings
        viewko.addBindings rootSelector, bindings


    ###
    Knockout Functions

    @method ko
    @return {Object<Function>}
    ###
    ko: ->


      ###
      Creates a binding context in javascript for Knockout

      @method addBindings
      @param rootSelector {String} The root DOM id or class the bindings will be added to
      @param conventions {Object} The binding conventions defined in the component view model
      @return {Object}
      ###
      addBindings: (rootSelector, conventions) =>
        # Add the context of the View to the arguments
        args = _.toArray arguments
        args.push @
        # Add the bindings to Knockout
        conventions = ko.bindingConventions.conventions.apply @, args
        # Add the instance of bindings for the ViewModel
        @koInstance = ko.bindingConventions._activeInstance
        conventions


      ###
      Removes the bindings from the view model

      @method removeBindings
      ###
      removeBindings: =>
        if @koInstance
          @koInstance.removeConventions(@)
          ko.cleanNode(@el)


      ###
      Remove a single nodes' binding

      @method removeBinding
      @param node {String} The #id or .class of the node
      @param root {String} The root selector of the node
      ###
      removeBinding: (node, root) ->
        if @koInstance
          @koInstance.conventions[node] = ((bindings, root) ->
            _.reject bindings, (binding) ->
              if root? and root is binding.rootSelector and binding.context is @
                @$el.find(root).find(node).remove()
                true
              else if not root? and binding.context is @
                @$el.find(node).remove()
                true
              else
                false
          )(_.find(@koInstance.conventions, (bindings, selector) -> node is selector), root)

          if @koInstance.conventions[node].length is 0
            delete @koInstance.conventions[node]


      ###
      Get the bindings

      @method getBindings
      @return {Object}
      ###
      getBindings: ->
        @koInstance.getBindings(@el, @)  if @koInstance


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
