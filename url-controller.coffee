'use strict'

define (require) ->
  Fulcrum = {}
  Helpers = require("./helpers/_helpers_")

  ###
  URL controller is used to trigger events and dom changes when there is a url change.
  ###
  class Fulcrum.UrlController

    ###
    The parent container for activation and deactivation of components

    @property {JQueryElement}
    ###
    scope: null


    ###
    Routes defined by the modules

    @property {Object}
    ###
    allHandles: null


    ###
    Router helper

    @property {Fulcrum.Helpers.Router}
    ###
    router: null


    ###
    Mediator helper

    @property {Fulcrum.Helpers.Mediator}
    ###
    mediator: null


    ###
    Constructor

    @param scope {JQueryElement} The jQuery element to which the routed components get attached to.
    ###
    constructor: (scope) ->
      @scope = scope
      @allHandles = {}
      @router = new Helpers.Router()
      @mediator = new Helpers.Mediator()

      # Listen to the DOM events of parent element of this controller to get any
      # deactivation calls. Upon deactivation call we will ask all components on
      # this parent element to deactivate them.
      @scope.bind "DEACTIVATE_HANDLERS", =>
        for handler of @allHandles
          @allHandles[handler].deactivate()  if @allHandles.hasOwnProperty(handler)
        @


    ###
    Wrapper for handles. This allows us to intercept activation calls so
    that we are able to execute custom logic such as deactivation of
    other handles.

    @method Wrapper
    @private
    @param handle {Object} Route-handler class
    @param scope {JQueryElement}
    ###
    Wrapper = (handle, scope) ->
      @handle = handle

      @activate = (params) =>
        # Deactivate all active handles (Components} in current controller
        scope.trigger "DEACTIVATE_HANDLERS"

        # Activate the requested handler (Component)
        @.handle.activate scope, params
        @

      @deactivate = =>
        @.handle.deactivate scope  if jQuery.isFunction(@.handle.deactivate)
        @

      @


    ###
    Trigger a route changed event

    @method routeChanged
    @param request {String} The route requests
    @param data {Object} The route object
    ###
    routeChanged: (request, data) ->
      @mediator.publish 'ROUTED', request: request, data: data


    ###
    Create handler objects from each route handler using the 'Wrapper' method and
    add the activated handler object to the router as routes.
    
    @method addRoutes
    @param handles {Array<Object>} route-handler object array
    @param track {Boolean} Track route change notifications
    ###
    addRoutes: (handles, track) ->
      for path of handles
        if handles.hasOwnProperty(path)
          handler = new Wrapper handles[path], @scope
          @router.addRoute path, handler.activate, track
          @allHandles[path] = handler

      @router.router.routed.add @routeChanged, @  if track?
      @router


    ###
    Remove a route.

    @method removeRoute
    @param route {String}
    ###
    removeRoute: (route) ->
      @router.removeRoute route


    ###
    Start the url controller by initializing the router
    
    @method start
    ###
    start: ->
      @router.init()


    ###
    Adds a new path to the router

    @method goTo
    @param {String} newPath New path
    ###
    @.goTo = (newPath) ->
      Helpers.Router.routeTo newPath


    ###
    Set the route without saving history
    @method redirectTo
    @param {String} newPath Hash code to update the url
    ###
    @.redirectTo = (newPath) ->
      Helpers.Router.redirectTo newPath


    ###
    Get the current route
    @method getRoute
    ###
    @.getRoute = ->
      Helpers.Router.getRoute()
