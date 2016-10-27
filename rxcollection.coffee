'use strict'

define (require) ->
  Phos      = {}
  Helpers   = require "./helpers/_helpers_"

  ###
  RXCollection
  ###
  class Phos.RXCollection

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

    @property {Phos.RXModel}
    ###
    model: null
    collection: null

    ###
    Constructor

    @param collection {Backbone.Collection}
    @param RXModel {Phos.RXModel} RXModel constructor
    ###
    constructor: (collection, RXModel) ->

      # Backbone collection
      @collection = collection

      # RXModel constructor
      @model      = RXModel

      rc = rx.array(_.map collection.models, (model) => new @model(model) )

      @collection.on(
        add: (model) => rc.push new @model(model)
        remove: (model, collection, options) -> rc.removeAt(options.index)
      )

      _.extend @, rc
