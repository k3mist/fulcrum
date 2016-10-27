'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = Helpers: {}

  Labels = require('Labels')

  ###
  Localizer is used to handle the localization aspects by providing the functions
  required for setting a different language and resetting the user language settings to the defaults.
  ###
  class Fulcrum.Helpers.Localizer

    ###
    Constructor
    ###
    constructor: ->
      @


    ###
    Apply localization to the given text.

    @method localize
    @static
    @param text {String} String that need to be localized. Tags should be in the form nls.your_tag_name
    @param locale {String} locale
    @return {String} localized text
    ###
    @.localize = (text, locale) ->
      return text  unless locale
      compiled = _.template text
      compiled(nls: Labels.translations[locale])


    ###
    Translate a key

    @method getString
    @param key {String}
    @param locale {String}
    @return {String} The localized string
    ###
    @.getString = (key, locale) ->
      if key? and key isnt ''
        @.localize "{{nls.#{key}}}", (if locale? then locale else I18n.locale)
      else
        ''


    ###
    Translate a key

    @method t
    @alias getString
    @param key {String}
    @param locale {String}
    @return {String} The localized string
    ###
    @.t = (key, locale) -> @.getString key, locale
