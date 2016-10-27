'use strict'

define (require) ->
  Phos          = {}
  RXModel       = require './rxmodel'
  RXCollection  = require './rxcollection'
  Helpers       = require "./helpers/_helpers_"

  bind = rx.bind
  rx.rxt.importTags()

  ###
  An abstraction of the Marionette ItemView and Layout View

  For more detailed information visit:
  https://github.com/marionettejs/backbone.marionette/blob/master/docs/marionette.view.md
  ###
  class Phos.RXView

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
    The Reactive View

    @property {Object}
    ###
    rxBindings: null


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

      # Prepend the stylesheet
      if @style? and @template?
        @template = "<span>#{Helpers.HTML.scopedCSS(@template, @style).html()}</span>"
        # Default to body if no template
      else if @style?
        @template = "<span>#{Helpers.HTML.scopedCSS('body', @style).html()}</span>"

      # Create the Marionette View
      RXView = Backbone.Marionette[@viewType].extend(@)

      # Initialize the View and pass the ko view helper as an option
      _.extend @, new RXView(
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
          new RXCollection(@collection, RXModel)
        else if @viewData? and typeof @viewData is 'object'
          @model = @viewData
          new RXModel(@model)
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
    Render the view
    Note: Overrides Marionette

    @method render
    ###
    render: ->
      parent = @options.parent()
      parent.isClosed = false

      parent.triggerMethod("before:render", @)
      parent.triggerMethod("item:before:render", @)

      data = parent.serializeData()
      data = parent.mixinTemplateHelpers(data)

      template = parent.getTemplate()
      html = Backbone.Marionette.Renderer.render(template, data)

      parent.$el.html(html)
      parent.affixView()
      parent.bindUIElements()

      parent.triggerMethod("render", @)
      parent.triggerMethod("item:rendered", @)


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
      @options.parent().jqBindings = null
      @$el.remove()


    ###
    Handles any actions that need to be taken on the View  when the DOM is refreshed.

    @method onDomRefresh
    @placeholder
    ###
    onDomRefresh: ->


    ###
    Affix the Reactive view

    @method affixView
    @param rxHtml {jQuery Element}
    @placeholder
    ###
    affixView: (rxHtml) ->
      @options.parent().$el.append(rxHtml).load(
        @options.parent().jqueryBindings()
      )


    ###
    Affix the jQuery bindings to the View

    @method affixBindings
    @placeholder
    ###
    jqueryBindings: -> @jqBindings = null


    ###
    Concat Reactive arrays

    @method concat
    @param arrays {Array} An array of reactive array groups
    ###
    concat: (arrays) ->
      start = arrays.shift arrays
      for array in arrays
        start = start.concat array
      start


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
