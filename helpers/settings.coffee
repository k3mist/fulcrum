'use strict'

define (require) ->
  _       = require 'underscore'
  Phos    = Helpers: {}
  Logger  = require './logger'

  ###
  Settings is used to propagate data through each context from the very point of
  application initialization to the context of each module and component.
  ###
  class Phos.Helpers.Settings

    ###
    Console logging

    @private
    @property {Phos.Helpers.Logger}
    ###
    logger = new Logger()


    ###
    Settings chaining will enable or disable the ability for sub contexts to
    access the settings / properties of any parent context.

    @private
    @property {Boolean} isSettingsChained Turn on or off settings chaining
    ###
    isSettingsChained = true


    ###
    A small utility function to find a property and cache the result.

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
      @param settings {Object} Settings class object
      ###
      constructor: (settings) ->
        @settings = settings


      ###
      Clear the cache

      @method clear
      ###
      clear: ->
        @store = {}
        @


      ###
      Set a cache value

      @method get
      @param item {String} The key to set
      @return {Mixed}
      ###
      set: (item) ->
        unless @store[item]
          obj = @settings.items()
          keys = item.split('.')
          (obj = obj[key]  if obj) for key in keys
          @store[item] = obj

        @store[item]


      ###
      Get a property value

      @method get
      @param item {String} The key to search for
      @return {Mixed}
      ###
      get: (item) ->
        # Set the cache
        @set item

        # Fall back to the settings items if our data is lacking
        # TODO Has to be a better way
        ((stored) =>
          # Check for object, the number check is for backbone collections
          if stored and 'object' is typeof stored and ('number' is typeof stored.length or _.keys(stored).length > 0)
            stored
          # Check for string
          else if stored and 'string' is typeof stored and stored.length isnt 0
            stored
          # Check for function
          else if stored and 'function' is typeof stored
            stored
          # Non-cache hit
          else
            @store[item] = @settings.items()[item]
        )(@store[item])


    ###
    Settings cache

    @property {Object}
    ###
    cache: new Cache()


    ###
    The parent settings

    @property {Phos.Helpers.Settings}
    ###
    parentSettings: null


    ###
    The settings of the current instance

    @property {Phos.Helpers.Settings}
    ###
    localSettings: null


    ###
    Constructor

    @param parentSettings {Phos.Helpers.Settings} Optional inheritance of settings from a parent context
    ###
    constructor: (parentSettings) ->
      @parentSettings = parentSettings
      @localSettings = {}
      @cache = new Cache(@) # Create a new cache to respect the context of each module


    ###
    Extends the local settings with the new settings

    @method load
    @param newSettings {Object} Object containing the new settings
    ###
    load: (newSettings) ->
      _.extend @localSettings, newSettings
      @cache.clear()


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
      @cache.clear()
