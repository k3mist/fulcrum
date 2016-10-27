'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = Helpers: {}

  ###
  Settings is used to propagate data through each context from the very point of
  application initialization to the context of each module and component.
  ###
  class Fulcrum.Helpers.Settings

    ###
    @private
    @property {Boolean} 'isSettingsChained' State whether or not the settings has been chained
    ###
    isSettingsChained = true


    ###
    A small utility function to find a deep property and cache the result.

    @private
    @property {Function}
    ###
    class Cache

      ###
      Internal items

      @property {Object}
      ###
      items: {}


      ###
      Internal cache

      @property {Object}
      ###
      store: {}


      ###
      @param items {Object} Items object
      ###
      constructor: (items) ->
        @items = items  if items


      ###
      Update the items

      @method update
      @param items {Object} Items object
      ###
      update: (items) -> @items = items


      ###
      Clear the cache

      @method clear
      ###
      clear: ->
        @store = {}
        @


      ###
      Get a property value

      @method get
      @param item {String} The key to search for
      @return {Mixed}
      ###
      get: (item) ->
        unless @store[item]
          obj = @items
          keys = item.split('.')
          (obj = obj[key]  if obj) for key in keys
          @store[item] = obj

        @store[item]


    ###
    Settings cache

    @property {Object}
    ###
    cache: new Cache()


    ###
    The parent settings

    @property {Fulcrum.Helpers.Settings}
    ###
    parentSettings: null


    ###
    The settings of the current instance

    @property {Fulcrum.Helpers.Settings}
    ###
    localSettings: null


    ###
    Constructor

    @param parentSettings {Fulcrum.Helpers.Settings} Optional inheritance of settings from a parent context
    ###
    constructor: (parentSettings) ->
      @parentSettings = parentSettings
      @localSettings = {}
      @cache = new Cache() # Create a new cache to respect the context of each module
      @cache.update @items() # Add the settings from the parent context (if they are set)


    ###
    Extends the local settings with the new settings

    @method load
    @param newSettings {Object} Object containing the new settings
    ###
    load: (newSettings) ->
      _.extend @localSettings, newSettings
      @cache.clear().update @items()


    ###
    Returns the local settings

    @method items
    @return {Object} localSettings
    ###
    items: ->
      if isSettingsChained and @parentSettings
        # Override parent settings and preserve the parent context
        _.extend _.clone(@parentSettings.items()), @localSettings
      else
        @localSettings


    ###
    Find a defined setting

    @method find
    @param setting {String}
    @return {Mixed}
    ###
    find: (setting) ->
      @cache.get setting


    ###
    Set the state of the settings chaining

    @method chainSettings
    @param isChained {Boolean}
    ###
    chainSettings: (isChained) ->
      isSettingsChained = isChained
      @cache.clear().update @items()
