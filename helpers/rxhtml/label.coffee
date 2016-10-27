'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Label

    logger = new Logger()

    # Form label
    form: (attr, text, required = false, options = {}) ->
      styles = "control-label"
      styles = "#{styles} required" if required
      styles = "#{styles} #{options.class}" if options.class?
      styles = "#{styles} col-sm-5" unless options.class?.match(/col\-/)
      options.class = styles
      label _.extend({class: styles, for: attr}, options), text

