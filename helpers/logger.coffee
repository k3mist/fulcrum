'use strict'

define (require) ->
  Fulcrum = Helpers: {}

  ###
  Logger is used when we want to log something (some information or error) on the server side as it can be referred later
  ###
  class Fulcrum.Helpers.Logger

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
    Print the input string message on the console as a log

    @method info
    @param {String} msg
    ###
    info: (msg) ->
      console.log msg  if console? and @initialized


    ###
    Print the input string message on the console log as an error

    @method error
    @param {String} msg
    @param {String} error
    ###
    error: (msg, error) ->
      if console? and @initialized
        console.log "ERROR : " + msg
        console.error error
