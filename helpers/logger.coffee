'use strict'

define (require) ->
  Phos = Helpers: {}

  ###
  A simple logging mechanism
  ###
  class Phos.Helpers.Logger

    ###
    Logger initialized

    @property {Boolean}
    ###
    initialized: false


    ###
    Constructor
    ###
    constructor: ->
      @initialized = true


    ###
    Print a message to the console

    @method info
    @param {String} message
    ###
    info: (message) ->
      console.log.apply console, arguments  if console? and @initialized


    ###
    Print a message to the console as an error

    @method error
    @param {String} message
    @param {String} error
    ###
    error: (message, error) ->
      console.error.apply console, arguments  if console? and @initialized


    ###
    Print a message to the console as a warning

    @method warn
    @param {String} message
    ###
    warn: (message) ->
      console.warn.apply console, arguments  if console? and @initialized
