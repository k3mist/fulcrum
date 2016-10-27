'use strict'

define (require) ->

  ###
  Namespace variable defining helper classes mainly used by the core classes in 'Fulcrum' namespace.

  @type Script
  @namespace Fulcrum.Helpers
  @module FulcrumCoreClasses
  @main FulcrumCoreClasses
  ###
  Localizer: require("./localizer")
  Logger: require("./logger")
  Mediator: require("./mediator")
  Router: require("./router")
  Settings: require("./settings")
  Styler: require("./styler")
  ViewHelper: require("./view-helper")
