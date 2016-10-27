'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  tr      = require 'core/helpers/translate'
  Form    = require './form'
  Label   = require './label'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Button

    logger = new Logger()

    Form: new Form()

    Label: new Label()

    # Dev button
    dev: (text, opts = {}) ->
      opts = _.extend({
        type: 'button'
        class: 'btn btn-danger btn-xs btn-dev'
      }, opts)
      button opts, text

    # Standard link button
    link: (text, opts = {}) ->
      opts.class = "btn btn-default #{if opts.class? then opts.class else ''}"
      opts = _.extend({
        type: 'button'
      }, opts)

      if opts.processing?
        processing = opts.processing
        button opts,  bind -> _.compact([
          i({class: 'fa fa-fw fa-save'}) if not processing.get()
          text if not processing.get()
          i({class: 'fa fa-fw fa-circle-o-notch fa-spin'}) if processing.get()
          '...' if processing.get()
        ])
      else
        button opts, text

    # Form field delete button
    delete: (opts = {}) ->
      opts = _.extend({
        type: 'button'
        class: 'btn btn-danger btn-sm'
      }, opts)
      button opts, tr.common('delete_button_label')

    # Right aligned form group button
    block: (text, opts = {}) ->
      $el = @Form.group(@Label.form('', ''),
        @link(text, opts)
      )

      if opts.text? and opts.text is 'right'
        $el.find('.col-sm-7').addClass('text-right')

      $el
