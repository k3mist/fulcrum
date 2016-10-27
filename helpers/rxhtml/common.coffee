'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  Form    = require 'core/helpers/form'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Common

    logger = new Logger()

    # Spacer
    spacer: (size = 'md') -> div {class: "spacer-#{size}"}

    # Spacer with Horizontal Rule
    spacerHr: -> div {class: 'spacer-md'}, hr {}

    # Title
    title: (text) -> [
      h3 {}, text
      div {class: 'spacer-md'}
    ]

    # Title with alert box
    titleInfo: (text, alert) -> [
      h3 {}, text
      div {class: 'alert alert-info'}, alert
      div {class: 'spacer-md'}
    ]