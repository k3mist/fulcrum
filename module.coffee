'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')

  Fulcrum = {}
  Helpers = require("./helpers/_helpers_")

  ###
  The Module class provides a simple interface to store and initialize modules
  and components. Each module and component within creates their own context and
  inherits the context of the parent module.

  TODO: Add global routing for Module
  ###
  class Fulcrum.Module

    ###
    Context

    @property {Fulcrum.Context}
    ###
    context: null


    ###
    Modules

    @property {Function<Fulcrum.Module>}
    ###
    modules: ko.observableArray()


    ###
    Components

    @property {Function<Fulcrum.Component>}
    ###
    components: ko.observableArray()


    ###
    Logger

    @property {Fulcrum.Helpers.Logger}
    ###
    logger: new Helpers.Logger()


    ###
    Pre instantiated Modules and Components for reactivation

    @property {Object<Array>}
    ###
    __pre__: modules: [], components: []


    ###
    Initialize the Module

    @param options {Object}
    @option options {Fulcrum.Context} context Context for the modules and components
    @option options {Array<Fulcrum.Component>} components Array of components
    @option options {Array<Fulcrum.Module>} modules Array of modules
    ###
    constructor: (options) ->
      @context = options.context

      # Create the observable arrays for the modules and components
      for property in ['modules', 'components']
        @[property] = ko.observableArray()

      # Create the object for the pre instantiated modules and components.
      @__pre__ = modules: [], components: []

      # Add the sub modules to the Module.
      @addModules options.modules  if options.modules?

      # Add the components to the Module.
      @addComponents options.components  if options.components?


    ###
    Activate the components and modules

    @method activate
    ###
    activate: ->
      @activateComponents()
      @activateModules()
      @


    ###
    Deactivate the module. This will deactivate any sub modules and components.
    Technically this does not change the Module and the Module can be reactivated
    by simply calling activate()

    Components will run their deactivation procedure removing the view model
    bindings, jquery bindings, and the view template from the document.

    TODO: Remove component routes and add reactivation procedure

    @method deactivate
    ###
    deactivate: ->
      # Deactivate the Components
      for index, Component of @components()
        unless typeof Component is 'function'
          Component.controller.removeRoute(Component.route)  if Component.route?
          Component.deactivate()

      # Deactivate the Modules
      for index, Module of @modules()
        unless typeof Module is 'function'
          Module.deactivate()

      # Remove the Sub Modules and Components from the Module
      for property in ['modules', 'components']
        @[property].removeAll()

      # Add the pre-initialized sub Modules and Components back onto the Module
      @addModules @__pre__.modules
      @addComponents @__pre__.components
      @


    ###
    Activate the modules

    @method activateModules
    @return {Array} All modules currently loaded
    ###
    activateModules: ->
      for index, Module of @modules()
        if typeof Module is 'function'
          @modules()[index] = new Module context: @context
        else
          Module.activate @context

      @modules()


    ###
    Activate the components

    @method activateModules
    @return {Array} All components currently loaded
    ###
    activateComponents: ->
      for index, Component of @components()
        if typeof Component is 'function'
          @components()[index] = new Component context: @context
        else
          Component.activate  if Component.constructor? then Component.parent else @context

      @components()


    ###
    Add modules

    @method addModules
    @param modules {Array<Fulcrum.Module>}
    ###
    addModules: (modules) ->
      for module in modules
        @modules.push module
        @__pre__.modules.push module


    ###
    Add components

    @method addComponents
    @param modules {Array<Fulcrum.Component>}
    ###
    addComponents: (components) ->
      for component in components
        @components.push component
        @__pre__.components.push component
