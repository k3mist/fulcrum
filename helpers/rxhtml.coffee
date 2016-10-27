'use strict'

define (require) ->
  Phos    = Helpers: {}
  Logger  = require './logger'

  Common = require './rxhtml/common'
  Events = require './rxhtml/events'
  Modal = require './rxhtml/modal'
  Form = require './rxhtml/form'
  Field = require './rxhtml/field'
  Hours = require './rxhtml/hours'
  Label = require './rxhtml/label'
  Button = require './rxhtml/button'

  bind = rx.bind
  rx.rxt.importTags()

  ###
  HTML is used to help with the View
  ###
  class Phos.Helpers.RXHtml

    logger = new Logger()

    # Common
    @.Common = new Common()

    # Events
    @.Events = new Events()

    # Modal
    @.Modal = new Modal()

    # Form
    @.Form = new Form()

    # Hours
    @.Hours = new Hours()

    # Label
    @.Label = new Label()

    # Field
    @.Field = new Field()

    # Button
    @.Button = new Button()