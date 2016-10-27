'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')
  ko.mapping = require('koMapping')

  Fulcrum = {}
  Fulcrum.Collection = require('./collection')
  Helpers = require("./helpers/_helpers_")

  ###
  The Model class handles Knockout driven model's for data storage and business logic.
  ###
  class Fulcrum.Model

    ###
    Protected Index's

    @private
    @property {Array}
    ###
    _reserved = [
      '__ko_mapping__'
      'constructor'
      'mapping'
      'uri'
      'i18nKey'
      'fileData'
      'logger'
      'put'
      'patch'
      'post'
      'get'
      'show'
      'create'
      'update'
      'delete'
      'destroy'
      'clear'
      'revert'
    ]


    ###
    Set ignored model keys from the model's map.ignore object and the _reserved keys list

    @private
    @method setIgnore
    @param model {Fulcrum.Model} The current instance
    @param mapping {Object} The mapping of the current instance
    ###
    setIgnore = (model, mapping) ->
      _.union mapping.ignore, _reserved, _.map(model, (e, i) ->
        i  if (ko.isObservable(model[i])) and mapping.include.indexOf(i) is -1
      )


    ###
    Sanitize the json by removing any reserved keys from the object.

    @private
    @method sanitize
    @param json {Object}
    @param ignore {Array}
    @return {Object}
    ###
    sanitize = (json, ignore) ->
      (delete json[key]  if key in ignore)  for key of json
      json


    ###
    Create a new json object from the model's mapping include sanitized json object

    @private
    @method fill
    @param mapping {Object}
    @param json {Object}
    ###
    fill = (mapping, json) ->
      (json[key] = ''  if typeof json[key] is 'undefined')  for key in mapping.include
      json


    ###
    Mapping
    http://knockoutjs.com/documentation/plugins-mapping.html

    @property {Object}
    ###
    mapping:
      include: []
      ignore: _reserved


    ###
    The key for the I18n translations. Should map to the root of the translation
    label requested. For example, if the label needed is 'person.firstname_label'
    set this to 'person'

    @property {String}
    ###
    I18nKey: null


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
      # Allow models to be created with no data.
      json = {}  if typeof json isnt 'object' or not json

      # Set ignore keys.
      @mapping.ignore = setIgnore @, @mapping

      # Map the JSON to Knockout observables
      mapped = ko.mapping.fromJS fill(@mapping, sanitize(json, @mapping.ignore)), @mapping, @

      # Convert arrays to a Collection if it has a Model
      for e in @mapping.include
        if mapped[e]? and ko.isObservable(mapped[e]) and @mapping[e]?.model?
          # Set an empty array if no data was provided for the Collection
          json[e] = []  unless _.isArray(mapped[e]())
          # Create the Collection
          @[e] = new Fulcrum.Collection json[e], @mapping[e].model()

      # Allow extended classes access to the mapped knockout object.
      return mapped


    ###
    ----------------------------------------------------------------------------
    UTILITY
    ----------------------------------------------------------------------------
    ###


    ###
    Get model observables as JSON

    @method toJSON
    @return {Object}
    ###
    toJSON: ->
      ko.mapping.toJS @, @mapping


    ###
    Stringify model from JSON
    Used in the majority of all ajax post, put, get, and delete requests

    @method asString
    @return {String}
    ###
    asString: ->
      JSON.stringify(@toJSON())


    ###
    ----------------------------------------------------------------------------
    UNDERSCORE JS
    ----------------------------------------------------------------------------
    ###

    ###
    UnderscoreJS inheritance.

    Supports the following UnderscoreJS methods;
    each, map, find, filter, reject, every, some, sortBy, groupBy, countBy.

    Technically, if you pass the UnderscoreJS method you want to use as the
    first argument and the arguments you want UnderscoreJS to execute as an
    array for the second argument, you should be able to use any UnderscoreJS
    method on the Model.

    @method _
    @return {Mixed}
    ###
    _: ->
      args = _.toArray arguments[1]
      args.unshift _.pick(@, _.keys(@toJSON()))
      _[arguments[0]].apply @, args

    ###
    @method each
    ###
    each: -> @_('each', arguments)
    ###
    @method map
    ###
    map: -> @_('map', arguments)
    ###
    @method find
    ###
    find: -> @_('find', arguments)
    ###
    @method filter
    ###
    filter: -> @_('filter', arguments)
    ###
    @method reject
    ###
    reject: -> @_('reject', arguments)
    ###
    @method every
    ###
    every: -> @_('every', arguments)
    ###
    @method some
    ###
    some: -> @_('some', arguments)
    ###
    @method sortBy
    ###
    sortBy: -> @_('sortBy', arguments)
    ###
    @method groupBy
    ###
    groupBy: -> @_('groupBy', arguments)
    ###
    @method countBy
    ###
    countBy: -> @_('countBy', arguments)
