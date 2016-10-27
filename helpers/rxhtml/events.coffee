'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  Form    = require 'core/helpers/form'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Events

    logger = new Logger()

    # Slide
    slide: (cell, $el, matches) ->
      switch cell.constructor.name
        when 'SrcCell'
          rx.autoSub cell.onSet, ([oldVal, newVal]) ->
            if newVal in matches then $el.slideDown() else $el.slideUp()
        when 'SrcArray'
          rx.autoSub cell.onSet, ([index, added, removed]) ->
            if added in matches then $el.slideDown() else $el.slideUp()
        when 'SrcMap'
          rx.autoSub cell.onSet, ([cKey, oldVal, newVal]) ->
            if newVal is matches[cKey] then $el.slideDown() else $el.slideUp()