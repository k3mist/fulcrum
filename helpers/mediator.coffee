'use strict'

define (require) ->
  Fulcrum = Helpers: {}

  pubsub = require('pubsub')

  ###
  Mediator is used for handling the messaging inside the framework
  ###
  class Fulcrum.Helpers.Mediator

    ###
    PubSub JS

    @property {Object}
    ###
    pubsub: null


    ###
    Constructor
    ###
    constructor: ->
      @pubsub = pubsub


    ###
    Notify others on an occurrence of an event by setting up a publish point with a string
    
    @method publish
    
    @param event {String} Event to publish
    @param params {Object/Function}
    ###
    publish: (event, params) ->
      @pubsub.publish event, params


    ###
    Notify others on an occurrence of an event by setting up a publish point with a string
    This method run all events synchronously and should only be needed in testing.

    @method publishSync

    @param event {String} Event to publish
    @param params {Object/Function}
    ###
    publishSync: (event, params) ->
      @pubsub.publishSync event, params


    ###
    listen to the events published by others by registering a callback on a named event
    
    @method subscribe
    
    @param event {String} Event to subscribe the callback function
    @param fn {Function} Callback function
    ###
    subscribe: (event, fn) ->
      @pubsub.subscribe event, fn


    ###
    Unsubcribe a tokenized subscription

    @method unsubscribe

    @param token {Object} The token (saved) subscriber
    ###
    unsubscribe: (token) ->
      @pubsub.unsubscribe token
