'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  tr      = require 'core/helpers/translate'
  Field   = require './field'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Hours

    logger = new Logger()

    Field: new Field()

    # Hours container
    init: (prefix, values, work_days) ->
      work_days.map (day) => @row(prefix, day.value, values, day.text)

    # Hour row (am, pm, closed)
    row: (name, attr, values, text) ->
      # Cells
      closed  = rx.cell values.get(attr).closed
      am      = rx.cell values.get(attr).am
      pm      = rx.cell values.get(attr).pm

      # Hour input
      hourInput = (ampm, cell) ->
        $input = input {
          name: "#{name}[#{attr}][#{ampm}]"
          class: "spinner hour-#{ampm}"
          value: bind -> cell.get()
          blur: ->
            obj = values.get attr
            obj[ampm] = @val()
            values.put attr, obj
          change: ->
            obj = values.get attr
            obj[ampm] = @val()
            values.put attr, obj
        }

        cell.onSet.sub rx.skipFirst ([oldVal, newVal]) ->
          $input.val newVal

        $input

      switchInput = => @Field.buttonSwitch("#{name}[#{attr}][closed]", closed, {
          text: tr.employer('office_hours_closed_label')
          value: true
        }, {}, 'checkbox')

      # Hours row
      $el = div {class: 'row', style: 'margin-bottom: 2px;'}, [
        div {class: 'col-xs-1'}, [
          label {class: 'control-label'}, text
        ]
        div {class: 'col-xs-8'}, [
          div {class: 'input-group'}, [
            span {class: 'input-group-addon'}, [ i {class: 'fa fa-clock-o'}]
            hourInput('am', am)
            span {class: 'input-group-addon', style: 'border-left:0;border-right:0;'}, tr.common('am')
            hourInput('pm', pm)
            span {class: 'input-group-addon'}, tr.common('pm')
          ]
        ]
        div {class: 'col-xs-3'}, [
          switchInput()
        ]
      ]

      # Apply time spinner
      $el.find('input.spinner').timespinner
        step: (60 * 1000) * 5
        page: 60

      # Add input group to spinner generated html
      $spinContainers = $el.find('.ui-spinner')
      $spinContainers.addClass 'input-group-addon'

      # Input Spinners
      $spinners = $el.find('input.spinner')

      # Switch
      $switch = $el.find('input.switch')

      # Disable spinners on page load
      if values.get(attr).closed in [true, "true"]
        $spinContainers.addClass 'disabled'
        $spinners.attr 'disabled', 'disabled'

      valueSub = -> values.onChange.sub ([key, oldVal, newVal]) ->
        if key is attr
          logger.info 'hour:', attr, 'key:', key, 'value:', newVal
          am.set newVal.am unless am.get() is newVal.am
          pm.set newVal.pm unless pm.get() is newVal.pm
          closed.set newVal.closed unless closed.get() is newVal.closed

      values.hSubs = {} unless values.hSubs
      values.hSubs[attr] = valueSub() unless values.hSubs[attr]?

      # Apply switch
      closed.onSet.sub rx.skipFirst ([oldVal, newVal]) ->
        obj = values.get attr
        obj.closed = newVal

        logger.info 'hour closed:', attr, 'value:', obj
        $switch.prop 'checked', obj.closed
        $switch.trigger 'change'

        if obj.closed is true
          $spinContainers.addClass 'disabled'
          $spinners.attr 'disabled', 'disabled'
        else
          $spinners.removeAttr 'disabled'
          $spinContainers.removeClass 'disabled'

        values.put attr, obj  unless values.get(attr) is obj

      am.onSet.sub rx.skipFirst ([oldVal, newVal]) ->
        obj = values.get attr
        obj.am = newVal
        logger.info 'hour am:', attr, 'value:', obj
        values.put attr, obj  unless values.get(attr) is obj

      pm.onSet.sub rx.skipFirst ([oldVal, newVal]) ->
        obj = values.get attr
        obj.pm = newVal
        logger.info 'hour pm:', attr, 'value:', obj
        values.put attr, obj  unless values.get(attr) is obj

      $el