'use strict'

define (require) ->
  Phos      = {}
  Helpers   = require "./helpers/_helpers_"
  RXCollection = require './rxcollection'

  ###
  RXModel
  ###
  class Phos.RXModel

    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Helpers.Logger()

    model: null
    json: null
    loading: true

    ###
    Constructor

    @param model {Phos.RXModel}
    ###
    constructor: (model) ->

      # Set the Backbone Model
      @model  = model

      # Get the JSON
      @json   = model.toJSON()

      # Reactive model
      rm = rx.map({})
      @loading = true

      # Iterate over the JSON object and create the reactive model attributes
      _.each @json, (value, key) =>
        # Collection
        if value? and @model.get(key)?.models?
          rm.put key, new RXCollection(@model.get(key), RXModel)
        # Model
        else if value? and @model.get(key).relations?
          rm.put key, new RXModel(@model.get(key))
        # Array
        else if _.isArray(value)
          rm.put key, rx.cell(value)
          rm.get(key).error = rx.cell null
          rm.get(key).onSet.sub rx.skipFirst ([oldVal, newVal]) =>
            logger.info key, 'rx array:', arguments
            @model.set key, newVal #, {silent: true}
        # Object
        else if value? and _.isObject(value)
          rm.put key, rx.map(value)
          rm.get(key).error = rx.cell null
          rm.get(key).onChange.sub rx.skipFirst ([cKey, oldVal, newVal]) =>
            logger.info key, 'rx map', arguments
            @model.set key, rm.get(key).all() #, {silent: true}
        # String, Boolean, Integer, etc
        else
          rm.put key, rx.cell(value)
          rm.get(key).error = rx.cell null
          rm.get(key).onSet.sub rx.skipFirst ([oldVal, newVal]) =>
            logger.info key, 'rx cell', arguments
            @model.set key, newVal #, {silent: true}

      # Listen for Backbone model changes to update the reactive model attribute
      @model.on 'change', (model) =>
        logger.info 'model', arguments
        _.each(model.changed, (value, key) =>
          rxValue = rm.get(key)

          # Update attribute
          updateAttribute = (x, v) ->
            switch x.constructor.name
              when 'SrcCell' then x.set(v) unless x.get() is v
              when 'SrcArray' then x.replace(v) if not x.all() in v
              when 'SrcMap' then x.update(v) unless x.all() is v

          # Check if attribute is actually a model
          if rxValue.model? and not rxValue.collection?
            _.each rxValue.all(), (cell, cellKey) -> updateAttribute cell, value[cellKey]
          else
            updateAttribute rxValue, value

        ) if not @loading

      @loading = false

      _.extend @, rm

      return @


    ###
    Set errors on the view model from the xhr request

    @method setErrors
    @param XHR {Object] The XHR request object
    ###
    setErrors: (xhr) ->
      setErrors = (rxModel, errors) ->
        _.each errors, (value, key) ->
          attr = rxModel.get(key)
          if attr.collection?
            _.each value, (subErrors, subIndex) ->
              setErrors attr.at(subIndex), subErrors
          else if attr.model?
            setErrors attr, value
          else if attr.error?
            attr.error.set value

      if xhr.responseJSON? and xhr.responseJSON.errors?
        setErrors @, xhr.responseJSON.errors

    clearErrors: ->

      clearErrors = (rxModel) ->
        _.each rxModel.all(), (value, key) ->
          attr = rxModel.get(key)
          if attr.collection?
            _.each attr.all(), (subModel) -> subModel.clearErrors()
          else if attr.model?
            attr.clearErrors()
          else if attr.error?
            attr.error.set null

      clearErrors @