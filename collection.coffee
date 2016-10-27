'use strict'

define (require) ->
  _ = require('underscore')
  ko = require('knockout')

  Fulcrum = {}
  Helpers = require("./helpers/_helpers_")

  ###
  The Collection class handles Collections of Model's for data storage and
  business logic. It essentially is an Observable Array with extended
  functionality.
  ###
  class Fulcrum.Collection

    ###
    Mapping

    @property {Object}
    ###
    mapping:
      include: []
      ignore: ['__ko_mapping__', 'constructor']


    ###
    The collection of models

    @property {Function<Array><Fulcrum.Model>}
    ###
    list: ko.observableArray()


    ###
    The model for the collection

    @property {Fulcrum.Model}
    ###
    model: null


    ###
    Initialize the Collection

    @param list {Array} Array list to convert to an array of models
    @param model {Fulcrum.Model} The Knockout Model to be created
    @return {Fulcrum.Collection / ObservableArray}
    ###
    constructor: (list, model) ->
      @list = ko.observableArray()
      @model = model

      # Create the entire Collection without notifying any subscribers
      underlyingList = @list.peek()
      @list.valueWillMutate()
      if _.isArray list
        (underlyingList.push.apply(underlyingList, [new @model(item)]) for item in list)
      @list.valueHasMutated()

      # Override knockout observableArray push and unshift functions so we can
      # create a model when adding to the array.
      _.each ["push", "unshift"], (method) =>
        @[method] = (data) =>
          underlyingArray = @list.peek()
          @list.valueWillMutate()
          result = underlyingArray[method].apply(underlyingArray, [new @model(data)])
          @list.valueHasMutated()
          result

      # Set ignore keys.
      @mapping.ignore = _.union @mapping.ignore, _.map(@, (e, i) ->
        i  if (ko.isObservable(model[i])) and mapping.include.indexOf(i) is -1
      )

      # The Majick
      return _.extend @list, @


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
      ko.mapping.toJS(@, @mapping)


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
    HELPERS
    ----------------------------------------------------------------------------
    ###

    ###
    Synchronize the collection

    @method synchronize
    @param response {Object}
    @param recursive {Boolean}
    @return {Fulcrum.Collection}
    ###
    synchronize: (response, recursive) ->
      @each (e, i) ->
        e.synchronize e.createResponse(response[i]), recursive
      @


    ###
    Clear dirty flag of each model. Should only ever be called on a
    successful response from the server.

    @method clearErrors
    @param recursive {Boolean} Also clear the dirty flag on sub models observables
    @return {Fulcrum.Collection}
    ###
    clearDirty: (recursive) ->
      @each (e, i) ->
        e.clearDirty recursive  if typeof e.clearDirty is 'function'
      @


    ###
    Revert the data on each model. This will only revert data back to its original
    value if the dirty flag was not cleared.

    @method revertModels
    @param recursive {Boolean} Also revert the data on sub models
    @return {Fulcrum.Collection}
    ###
    revertModels: (recursive) ->
      @each (e, i) ->
        e.revertModel recursive  if typeof e.revertModel is 'function'
      @


    ###
    ----------------------------------------------------------------------------
    UNDERSCORE JS
    ----------------------------------------------------------------------------
    ###

    ###
    UnderscoreJS inheritance.

    Supports the following UnderscoreJS methods;
    each, map, find, filter, reject, every, some, sortBy, groupBy, countBy,
    first, last, initial, rest.

    Technically, if you pass the UnderscoreJS method you want to use as the
    first argument and the arguments you want UnderscoreJS to execute as an
    array for the second argument, you should be able to use any UnderscoreJS
    method on the Collection.

    @method _
    @return {Mixed}
    ###
    _: ->
      args = _.toArray arguments[1]
      args.unshift @list.peek()
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
    ###
    @method first
    ###
    first: -> @_('first', arguments)
    ###
    @method last
    ###
    last: -> @_('last', arguments)
    ###
    @method initial
    ###
    initial: -> @_('initial', arguments)
    ###
    @method rest
    ###
    rest: -> @_('rest', arguments)
