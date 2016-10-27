'use strict'

define (require) ->

  ###
  Core classes

  @namespace Fulcrum
  @module FulcrumCoreClasses
  @main FulcrumCoreClasses
  ###
  Module: require('./core/module')
  Component: require('./core/component')
  Context: require('./core/context')
  DomController: require('./core/dom-controller')
  UrlController: require('./core/url-controller')
  Collection: require('./core/collection')
  Model: require('./core/model')
  Restful: require('./core/model-restful')
  ViewTemplate: require('./core/view-template')
  ViewModel: require('./core/view-model')
  ViewAffix: require('./core/view-affix')
  Routes: require('./core/routes')
  Helpers: require('./core/helpers/_helpers_')
