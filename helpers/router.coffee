'use strict'

define (require) ->
  _ = require('underscore')
  signals = require('signals')
  crossroads = require('crossroads')
  hasher = require('hasher')

  Fulcrum = Helpers: {}
  Fulcrum.Helpers.Logger = require('./logger')

  ###
  Router is used to handle url navigation by setting up routes and hash codes
  ###
  class Fulcrum.Helpers.Router

    ###
    Crossroads Router

    @property {Object}
    ###
    router: null


    ###
    Logger

    @property {Fulcrum.Helpers.Logger}
    ###
    logger: new Fulcrum.Helpers.Logger()


    ###
    Construtor

    @property {Object} 'router' Holds an instance of crossroads router
    ###
    constructor: ->
      @router = crossroads.create()
      @router.normalizeFn = crossroads.NORM_AS_OBJECT
      return @

    ###
    Creates a new route pattern and add it to crossroads routes collection

    @method addRoute
    @param pattern {String} String pattern that should be used to match against requests
    @param handler {Function} Function that should be executed when a request matches the route pattern
    ###
    addRoute: (pattern, handler, log) ->
      @router.addRoute pattern, handler
      @router.routed.add @logger.info, @logger  if log?
      @router


    ###
    Remove a route.

    @method removeRoute
    @param route {String}
    ###
    removeRoute: (route) ->
      routeObject = _.find @router._routes, (e) -> route.match(e._matchRegexp)
      @router.removeRoute(routeObject)  if routeObject?


    ###
    Initializes the router by parsing initial hash, parsing hash changes and initializing the hasher
    @method init
    ###
    init: ->
      parseHash = (newHash, oldHash) =>
        @router.parse newHash
      hasher.initialized.add parseHash # parse initial hash
      hasher.changed.add parseHash # parse hash changes
      hasher.init()  unless hasher.isActive() # start listening for history change


    ###
    Set the hash code to the url
    @method routeTo
    @param path {String} Hash code to update the url
    ###
    @.routeTo = (path) ->
      hasher.setHash path
      hasher


    ###
    Set the hash code to the url without saving history
    @method redirectTo
    @param path {String} Hash code to update the url
    ###
    @.redirectTo = (path) ->
      hasher.replaceHash path
      hasher

    ###
    Get the current route
    @method getRoute
    ###
    @.getRoute = ->
      hasher.getHash()
