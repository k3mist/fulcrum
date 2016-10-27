'use strict'

define (require) ->
  _         = require 'underscore'
  Backbone  = require 'backbone'
  require 'backbone.relational'
  Phos      = {}
  Helpers   = require "./helpers/_helpers_"

  ###
  Abstraction of the Backbone Model
  ###
  class Phos.Model extends Backbone.RelationalModel

    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Helpers.Logger()


    ###
    Model defaults

    @property {Object}
    ###
    defaults: {}


    ###
    The relations of the Model

        eg.
        relations: [
          {
            type: 'HasMany'
            key: 'phones'
            relatedModel: Phone
            collectionType: Phones
          }
          {
            type: 'HasOne'
            key: 'address'
            relatedModel: Address
          }
        ]
    @property {Array}
    ###
    relations: []


    ###
    Model Url

    Specify a urlRoot if you're using a model OUTSIDE of a collection to enable
    the default url function to generate URLs based on the model id.
    "[urlRoot]/id"

    @property {String/Function}
    ###
    urlRoot: null


    ###
    Errors holder.

    @property {Object}
    ###
    errors: {}


    ###
    Constructor

    @param json {Object}
    @param empty {Boolean}
    ###
    constructor: (json, empty) ->
      # Create an empty Model if the empty option is provided
      json = ((data) =>
        data = {}  if 'object' isnt typeof data or not data

        for key in _.keys(@defaults)
          data[key] = ''  if 'undefined' isnt typeof data[key]

        for relation in @relations
          unless data[relation.key]?
            if 'HasMany' is relation.type
              data[relation.key] = []
            else
              data[relation.key] = {}

        data
      )(json) if empty is true

      # Initialize the Model
      return super json


    ###
    Get the attributes on the Model. This is a safe way to work with Model
    attributes.

    @method getAttributes
    @return {Object}
    ###
    getAttributes: -> _.clone(@attributes)


    ###
    Add errors to the model and any relations.

    @method addErrors
    @param errors {Object}
    ###
    addErrors: (errors) ->
      @errors = {}
      _.each errors, (message, error) =>
        relation = @getRelation error
        if relation?.collectionType?
          _.each relation.related.models, (model, index) -> model.addErrors message[index]
        else if relation?.model?
          relation.related.addErrors message
        else
          @errors[error] = message
          @trigger "error-#{error}"

    ###
    Clear errors on the model and any relations.

    @method clearErrors
    ###
    clearErrors: ->
      _.each @getAttributes(), (value, attr) =>
        relation = @getRelation attr
        if relation?.collectionType?
          _.each relation.related.models, (model) -> model.clearErrors?()
        else if relation?.model?
          relation.related.clearErrors?()
        else
          @trigger "clear-error-#{attr}" if @errors?[attr]?


    ###
    Get the errors on the Model. This is a safe way to work with Model errors.

    @method getErrors
    @return {Object}
    ###
    getErrors: -> _.clone(@errors)


    ###
    Get the provided error.

    @method getError
    @param error {String}
    ###
    getError: (error) -> @errors[error] if @errors[error]

    ###
    Set the XHR method for setting the csrf token

    @method getTokenXHR
    @param options {Object}
    @return {Object}
    ###
    setTokenXHR: (options = {}) -> _.extend options,
      beforeSend: (xhr) -> xhr.setRequestHeader 'X-CSRF-Token', Helpers.Form.getToken().csrfToken

    ###
    Override Backbone.Model save and set token xhr header

    @method save
    @param key {String/Object}
    @param val {String/Object}
    @param options {Object}
    @return {Object}
    ###
    save: (key, val, options) ->
      if not key? or typeof key is "object"
        attrs = key
        options = val
      else
        (attrs = {})[key] = val

      super(attrs, @setTokenXHR(options)).fail (xhr) =>
        if xhr.status = 400 and xhr.responseJSON?.errors?
          @addErrors xhr.responseJSON.errors
          Helpers.HTML.modal 'common.error', ['common.missing_fields'], 'common.continue'
        else
          Helpers.HTML.xhrError xhr

    ###
    Override Backbone.Model destroy and set token xhr header

    @method destroy
    @param options {Object}
    @return {Object}
    ###
    destroy: (options = {}) -> super(@setTokenXHR(options)).fail (xhr) -> Helpers.HTML.xhrError xhr


  # Initialize the Model Relations
  Phos.Model.setup()
