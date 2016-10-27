'use strict'

define (require) ->
  _         = require 'underscore'
  Backbone  = require 'backbone'
  Phos      = Helpers: {}

  ###
  Abstraction of the Marionette/Backbone Router
  ###
  class Phos.Helpers.Router


    ###
    Restful methods

    @private
    @property {Object}
    ###
    _restful =
      index: ''
      create: '/new'
      show: '/:id'
      edit: '/:id/edit'


    ###
    Constructor

    @param options {Object}
    ###
    constructor: (options) ->
      # Check for restful on the route methods
      (=>
        for route, method of options.routes
          (=>
            for restMethod, restRoute of _restful
              options.routes["#{route}#{restRoute}"] = restMethod
            return
          )() if method is 'restful'
        return
      )() if options.routes?

      _.extend(@, new Backbone.Marionette.AppRouter(
        controller: options.controller
        appRoutes: options.routes
      ))


    ###
    Add routes to an already running Router

    @method addRoutes
    @param routes {Object}
    ###
    addRoutes: (routes) ->
      _.each routes, (method, route) =>
        @appRoute route, method


    ###
    Add a single route to an already running Router

    @method addRoute
    @param route {Object}
    ###
    addRoute: (route, method) ->
      @appRoute route, method


    ###
    Navigate to path

    @method navigateTo
    @param path {String}
    ###
    navigateTo: (path) -> @navigate path, trigger: true


    ###
    Redirect to path

    @method redirect
    @param path {String}
    ###
    redirect: (path) -> window.location.href = path