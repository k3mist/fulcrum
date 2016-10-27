'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')
  ko.dirtyFlag = require('koDirty')

  Fulcrum = {}
  Fulcrum.Model = require('./model')
  Helpers = require("./helpers/_helpers_")


  ###
  RESTful AJAX interface with helpers for managing the data within the model.
  In addition allows tracking changes to each data key and has internal error
  handling.
  ###
  class Fulcrum.Model.Restful extends Fulcrum.Model

    ###
    Resource URI. Used to identify the remote resource for the model. If set,
    RESTFul Ajax methods will be available to the Model along with other
    utilities and helpers.

    Setting a string will utilize that resource for all requests.

    Setting an object will lookup the HTTP verb for each request as a property
    on the @uri. You must specify ALL verbs (GET, POST, PUT, PATCH, DELETE).
    The only exception is if PATCH is not specified it will default to the uri
    provided for PUT.

    @property {String/Object}
    ###
    uri: null


    ###
    Additional file data that should be appended to the FormData object

    @property {Function<Array><Object>}
    ###
    fileData: null


    ###
    Model Errors

    @property {Function<Array>}
    ###
    errors: null


    ###
    Console logging

    @property {Fulcrum.Helpers.Logger}
    ###
    logger: new Helpers.Logger()


    ###
    Constructor

    @param json {Object} JSON to be inherited by the model and instantiated as observables.
    @return {Object} The mapped Knockout observables
    ###
    constructor: (json) ->

      # Set file data
      @fileData = ko.observableArray()

      # Model errors object
      @errors = _.extend ko.observableArray(), new ko.dirtyFlag(@errors, false)

      mapped = super

      # Dirty flag and revert support
      @each((item) ->
        if ko.isObservable(item)
          _.extend item, new ko.dirtyFlag(item, false)
          item.errors = ko.observableArray()
      )

      return mapped


    ###
    ----------------------------------------------------------------------------
    RESTFUL AJAX
    ----------------------------------------------------------------------------
    ###

    ###
    AJAX requests

    @method ajax
    @param verb {String} The HTTP verb to be used for the request
    @param recursive {Boolean}
    @return {Promise}
    ###
    ajax: (verb, recursive) ->
      # GET
      if verb is 'GET'
        options = data: @asParams()

      # POST, PUT, PATCH, DELETE
      else
        formData = @toFormData()

        options =
          processData: false
          contentType: false
          data: formData

        # Manually set content type and data for browsers without native FormData support
        _.extend(options,
          contentType: "multipart/form-data; boundary=#{formData.boundary}"
          data: formData.toString()
        )  if formData.fake?

        @fileData.removeAll()

      # Set the resource uri for this request
      uri = ((verb, uri) ->
        if typeof uri is 'string'
          uri
        else if verb is 'PATCH' and not uri['PATCH']?
          uri['PUT']
        else
          uri[verb]
      )(verb, @uri)

      # Response message I18n keys
      messages =
        GET: ''
        POST: 'create'
        PUT: 'update'
        PATCH: 'update'
        DELETE: 'delete'

      # AJAX
      $.ajax(
        _.extend(options,
          url: uri
          type: verb
        )
      ).done((response, statusText, xhr) =>
        switch xhr.status
          when 200, 201 # GET, POST
            @syncAndClear response, recursive

          when 204, 205 # PUT, PATCH, DELETE
            @empty([], recursive)  if verb is 'DELETE'
            @clearErrors(recursive).clearDirty(recursive)
            @show(recursive)  if xhr.status is 205

        xhr.response = @createResponse response, false, Helpers.Localizer.t("postaction.#{messages[verb]}d")

      ).fail((xhr, statusText, error) =>
        @logger.info "API ERROR : #{@ajaxError(xhr)}"

        # Error handling
        switch xhr.status
          when 401 # Unauthorized
            xhr.response = @createResponse {}, true, @ajaxError(xhr)
            # TODO figure out what to do with unauthorized requests
            #window.location.href = '/'  unless window.location.pathname is '/'

          when 422 # Unprocessable entity (likely validation failure)
            response = JSON.parse(xhr.responseText)
            @clearErrors(true).setErrors(response.data.errors)
            xhr.response = @createResponse response, true, Helpers.Localizer.t("postaction.#{messages[verb]}_failed")

          else # All other errors
            xhr.response = @createResponse {}, true, @ajaxError(xhr)

      )


    ###
    Show

    @method show
    @param recursive {Boolean}
    @return {Promise}
    ###
    show: (recursive) -> @ajax 'GET', recursive

    ###
    Create

    @method create
    @param recursive {Boolean}
    @return {Promise}
    ###
    create: (recursive) -> @ajax 'POST', recursive

    ###
    Update

    @method update
    @param recursive {Boolean}
    @return {Promise}
    ###
    update: (recursive) -> @ajax 'PUT', recursive

    ###
    Destroy

    @method destory
    @param recursive {Boolean}
    @return {Promise}
    ###
    destroy: (recursive) -> @ajax 'DELETE', recursive


    ###
    ----------------------------------------------------------------------------
    UTILITY
    ----------------------------------------------------------------------------
    ###


    ###
    Create FormData object from model JSON

    @method toFormData
    @return {Object}
    ###
    toFormData: ->
      formData = new FormData()
      @each (value, key) => formData.append key, if ko.isObservable(value) then value() else value
      _.each @fileData(), (value) -> formData.append value[0], value[1], value[2]
      formData


    ###
    Create a url ready string appending any key that ends with id as a parameter
    along with its value.

    @method asParams
    @return {String}
    ###
    asParams: ->
      _.compact(@map((value, param) ->
        "#{param}=#{value()}"  if param.match(/id$/)?
      )).join('&')


    ###
    ----------------------------------------------------------------------------
    HELPERS
    ----------------------------------------------------------------------------
    ###

    ###
    An all-in-one handler to update the model from the server response, clear
    any errors on the model and observables, and clear the dirty flag to erase
    any history on the observable.

    @method syncAndClear
    @param response {Object} The json response from the server
    @param recursive {Boolean} Also update the sub models
    @return {Fulcrum.Model.Restful}
    ###
    syncAndClear: (response, recursive) ->
      @synchronize(response, recursive).clearErrors(recursive).clearDirty(recursive)


    ###
    Update all the model observables from the server response

    @method synchronize
    @aliases sync
    @param response {Object} The json response from the server
    @param recursive {Boolean} Also update the data from the response on the sub models
    @return {Fulcrum.Model.Restful}
    ###
    synchronize: (response, recursive) ->
      @each (e, i) =>
        value = response.data[i]  if response.data[i]?
        ((e)->
          if ko.isObservable(e)
            # Update the collection
            if typeof e.synchronize is 'function'
              e.synchronize value, recursive
            # Update the observable
            else if e() isnt value
              e.valueWillMutate()
              e(value)
              e.valueHasMutated()

          # Update the sub model
          else if value? and recursive and typeof e.synchronize is 'function'
            e.synchronize e.createResponse(value), true
        )(e) if value?
      @


    ###
    Update all the model observables from the server response

    @method sync
    @alias synchronize
    @param response {Object} The json response from the server
    @param recursive {Boolean} Also update the data from the response on the sub models
    @return {Fulcrum.Model.Restful}
    ###
    sync: -> @synchronize.apply @, arguments


    ###
    Set errors on the model and the observables.
    This is recursive into the sub models if the response provides the key for
    that model.

    @method setErrors
    @param errors {Object} The errors from the rails model
    @return {Fulcrum.Model.Restful}
    ###
    setErrors: (errors) ->
      @errors.removeAll()
      _.each _.keys(errors), (key) =>
        # Set errors on the observable
        if ko.isObservable(@[key]) and key isnt 'errors'
          @[key].errors.removeAll()
          @[key].errors.push errors[key]

          # Set errors on the model
          _.each(errors[key], (error) =>
            @errors.push "#{Helpers.Localizer.t("#{@I18nKey}.#{key}_label")} #{error}"
          )  if @I18nKey?

          # Set errors on the sub model
        else if @[key]? and typeof @[key].setErrors is 'function' and errors[key].errors?
          @[key].setErrors errors[key].errors
      @


    ###
    Check if the model has errors

    @method hasErrors
    @param recursive {Boolean}
    @return {Boolean}
    ###
    hasErrors: (recursive) ->
      @filter((e, i) =>
        if ko.isObservable(e)
          e.errors().length > 0
        else if e.hasErrors? and recursive
          e.hasErrors true
        else
          false
      ).length > 0


    ###
    Get the errors set on the model and sub collections

    @method getErrors
    @param recursive {Boolean}
    @return {Array}
    ###
    getErrors: (recursive) ->
      errors = []
      # Model errors
      _.each @errors(), (error) -> errors.push(error)
      # Collection errors
      @each((e, i) =>
        _.each(e.errors(), (error) -> errors.push(error))  if e.getErrors?
      )  if recursive
      errors


    ###
    Clear errors on the model, observables, and collections.

    @method clearErrors
    @param recursive {Boolean} Also clear the dirty flag on sub models
    @return {Fulcrum.Model.Restful}
    ###
    clearErrors: (recursive) ->
      @errors.removeAll()
      @each (e, i) =>
        if ko.isObservable(e)
          e.errors.removeAll()
        else if recursive and e.clearErrors?
          e.clearErrors true
      @


    ###
    Check if the model has an observable that is marked dirty

    @method hasDirty
    @param recursive {Boolean}
    @return {Boolean}
    ###
    hasDirty: (recursive) ->
      @filter((e, i) =>
        if ko.isObservable(e)
          e.isDirty? and e.isDirty()
        else if recursive and e.hasDirty?
          e.hasDirty true
        else
          false
      ).length > 0


    ###
    Clear dirty flag of each observable. Should only ever be called on a
    successful response from the server.

    @method clearDirty
    @param recursive {Boolean} Also clear the dirty flag on sub models observables
    @return {Fulcrum.Model.Restful}
    ###
    clearDirty: (recursive) ->
      @errors.clearObservable()
      @each (e, i) =>
        if ko.isObservable(e)
          e.clearObservable()
          # Clear the Collection
          e.clearDirty recursive  if e.clearDirty?
        else if recursive and e.clearDirty?
          e.clearDirty true
      @


    ###
    Revert the data on the model. This will only revert data back to its original
    value if the dirty flag was not cleared.

    @method revertModel
    @param recursive {Boolean} Also revert the data on sub models
    @return {Fulcrum.Model.Restful}
    ###
    revertModel: (recursive) ->
      @errors.removeAll()
      @each (e, i) =>
        if ko.isObservable(e)
          e.errors.removeAll()
          e.revertObservable()
          e.valueHasMutated()
          # Revert the Collection
          e.revertModels recursive  if e.revertModels?
        else if recursive and e.revertModel?
          e.revertModel true
      @


    ###
    Empty the data on the model. This should only ever be used after
    deleting an entire resource.

    @method empty
    @param except {Array} Array of keys not to clear
    @param recursive {Boolean} Also clear the data on sub models (dangerous, use with extreme care)
    @return {Fulcrum.Model.Restful}
    ###
    empty: (except, recursive) ->
      @errors.removeAll()
      @errors.clearObservable()
      @each (e, i) =>
        ((e) ->
          if ko.isObservable(e)
            e.errors.removeAll()
            if _.isArray(e()) then e.removeAll() else e('')
            e.clearObservable()
            e.valueHasMutated()
          else if recursive and e.empty?
            e.empty except, true
        )(e) if typeof except is 'undefined' or i not in except
      @


    ###
    Create a fake server response.

    @method createResponse
    @param data {Object} The would be data from the server
    @param error {Boolean} The would be error status of the response
    @param message {String} The would be message of the response
    @return {Object}
    ###
    createResponse: (data, error, message) ->
      data: data
      error:
        status: error
        message: if error is true then message else ''
      message: message


    ###
    Parse rails error response

    @method ajaxError
    @param response {Object} The jquery error response object
    @return {String}
    ###
    ajaxError: (response) ->
      responseText = if response.responseText? then response.responseText else response.statusText
      if responseText? and not responseText.match(/^<!DOCTYPE html>/) and responseText.match(/^{/)
        parsed = JSON.parse(responseText)
      else
        parsed = false
      unless parsed.env? and parsed.env isnt 'development'
        response.statusText
      else
        parsed.error
