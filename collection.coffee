'use strict'

define (require) ->
  _         = require 'underscore'
  Backbone  = require 'backbone'
  Phos      = {}
  Helpers   = require "./helpers/_helpers_"

  ###
  Abstraction of the Backbone Collection
  ###
  class Phos.Collection extends Backbone.Collection

    ###
    Console logging

    @property {Phos.Helpers.Logger}
    ###
    logger = new Helpers.Logger()


    ###
    The Model to use for this Collection.

    The Model name must be a different name than the Collection. It is preferrable
    and best practice that the Collection is the plural version of the name used
    for the Model.

        eg. Collection --> People,  Model --> Person

    @property {Phos.Model}
    ###
    model: null


    ###
    Collection Url

    Set the url property (or function) on a collection to reference its location
    on the server. Models within the collection will use url to construct URLs
    of their own.

    @property {String/Function}
    ###
    url: null


    ###
    Constructor

    @param json {Object}
    ###
    constructor: (json) ->
      unless @model?
        return logger.error @constructor.name,
          'Please provide a Model to the Collection.'

      return super
