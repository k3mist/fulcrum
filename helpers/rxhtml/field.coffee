'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  Form    = require 'core/helpers/form'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Field

    logger = new Logger()


    # True / False value
    tfVal: (value) ->
      switch value
        when 'true' then true
        when 'false' then false
        else value


    # Field error div
    fieldError: (value) ->
      div {
        class: bind -> _.compact([
          'alert alert-danger alert-field-error'
          'hidden' unless value.error.get()?
        ]).join(' ')
      }, bind -> if value.error.get()? then value.error.get().join(', ') else ''


    # Check selected
    selected: (sOption, value) ->
      field = new Field()
      sOption.value = field.tfVal sOption.value
      x = field.tfVal value.get()

      if value.get()?
        (sOption.value in x or sOption.value is x)


    # Static
    static: (labelText, value) ->
      div {class: 'form-group'}, [
        label {class: "#{columnLabel} control-label"}, labelText
        div {class: columnField}, [
          p {class: 'form-control-static'}, value.get()
        ]
      ]


    # Input
    input: (name, placeholder, value, maxlength='', opts={}, type='text') ->
      inputOpts =
        class: 'form-control'
        placeholder: placeholder
        name: name
        type: type
        maxlength: maxlength
        value: bind -> value.get()
        change: -> value.set @val()

      _.extend(inputOpts, opts)

      if name is '' then _.extend(inputOpts, {disabled: true})

      if 'hidden' is type
        input(_.omit(inputOpts, ['class', 'placeholder']))
      else
        span {}, [
          input(inputOpts)
          @fieldError value
        ]

    # Textarea
    textarea: (name, value, opts={}) ->
      textareaOpts = _.extend {
        class: 'form-control'
        rows: 4
        name: name
        maxlength: 200
        change: -> value.set @val()
      }, opts
      textarea textareaOpts, bind -> value.get()


    # Spinner
    spinner: (name, placeholder, value, opts={}) ->
      _.extend opts,
        class: 'spinner'
      @input name, placeholder, value, '', opts


    # Select
    select: (attr, value, group, opts = {}) ->
      selected = @selected

      selectOpts =
        class: 'form-control'
        name: attr
        placeholder: if opts.placeholder then opts.placeholder else ''
        disabled: opts.disabled
        change: ->
          val = @val()
          logger.info attr, 'select change:', val
          value.set val unless val is value.get()

      opts.select2 = [] unless opts.select2?

      if opts.multiple?
        _.extend(selectOpts, {multiple: 'multiple'})
        opts.select2.push 'multiple' if opts.multiple?

      opts.select2.push 'noSearch' unless opts.noSearch is false
      opts.select2.push 'allowClear' if opts.allowClear

      $el = span {}, [
        select selectOpts, group.map (sOption) ->
          option {
            value: sOption.value
            selected: bind -> selected sOption, value
          }, sOption.text
        @fieldError value
      ]

      $select = $el.find('select')

      rx.autoSub value.onSet, rx.skipFirst ->
        logger.info attr, 'select2 update:', value.get()
        $select.select2 'val', value.get()

      $select.select2(
        _.extend({
            placeholder: if opts.placeholder then opts.placeholder else ''
          }, Form.select2(opts.select2)
        )
      )

      $el


    # Button group
    btnGroup: (attr, value, group, opts={}) ->
      checked = @selected
      opts = _.extend {
        groupSize: 'sm'
        colSize: 6
        type: 'radio'
        name: attr
        change: -> switch opts.type
          when 'radio' then value.set @val()
          when 'checkbox'
            if checked({value: @val()}, value)
              value.set _.without(value.get(), @val())
            else
              value.set _.union(value.get(), [@val()])
      }, opts

      span {}, [
        div {class: "btn-group btn-group-#{opts.groupSize} col-md-12", 'data-toggle': 'buttons'}, group.map (g) ->
          label {class: bind -> _.compact([
            "btn-primary btn col-md-#{opts.colSize}"
            'active' if checked(g, value)
          ])}, [
            input _.extend _.clone(opts), {
              value: g.value
              checked: bind -> checked g, value
            }
            g.text
          ]
        @fieldError value
      ]

    # Radios
    radios: (attr, value, radios, opts={}) ->
      @btnGroup attr, value, radios, _.extend {type: 'radio'}, opts

    # Checkboxes
    checkboxes: (attr, value, checkboxes, opts={}) ->
      @btnGroup attr, value, checkboxes, _.extend {type: 'checkbox'}, opts


    # Button switches
    switches: (attr, value, switches, opts={}, type = 'radio') ->
      $el = div {class: 'col-xs-12 switch-group'}, switches.map (sOption) =>
        @buttonSwitch attr, value, sOption, opts, type

      span {}, [
        $el
        div {class: 'clearfix col-xs-12'},
          @fieldError value
      ]


    # Button switch
    buttonSwitch: (attr, value, sOption, opts={}, type = 'radio') ->
      checked = @selected

      $el = label {class: 'switch', style: 'margin-top:6px;'}, [
        input _.extend
          type: type
          class: 'switch'
          name: attr
          value: sOption.value
          checked: bind -> checked sOption, value
        , opts
        " #{sOption.text}"
      ]

      $input = $el.find('input')

      # Update input on reactive changes
      value.onSet.sub rx.skipFirst ([oldVal, newVal]) ->
        if oldVal isnt newVal
          logger.info attr, 'switch value:', $input.val(), 'checked:', checked(sOption, value)
          $input.prop 'checked', checked sOption, value
          $input.trigger 'change', true

      # Init
      $input.bootstrapSwitch
        size: 'single'
        onSwitchChange: (event) ->
          logger.info arguments
          switchVal = switch $input.val()
            when 'true' then $input.is(':checked')
            when 'false' then false
            else $input.val()

          unless value.get() is switchVal
            logger.info attr, 'switch change:', value, 'value:', switchVal
            value.set switchVal

      # Disabled
      bind(->
        $input.bootstrapSwitch 'disabled', opts.disabled.get()
      ) if opts.disabled?

      $el


    ###
    Datepicker

    @method datepicker
    @param attr {String}
    @param placeholder {String}
    @param value {RXCell}
    @param opts {Object}
    ###
    datepicker: (attr, placeholder, value, opts={}) ->
      openDp = ($el) -> $el.closest('.input-group').find('input').datepicker('show')

      # Datepicker options
      dpOpts = _.extend {
        changeMonth: true
        changeYear: true
        showButtonPanel: true
      }, _.pick(opts, 'dateFormat')

      # Month only datepicker
      (->
        dpOpts.dateFormat = 'mm-yy'
        _.extend opts,
          focus: -> $('#ui-datepicker-div').find('.ui-datepicker-calendar').hide()
        _.extend dpOpts,
          beforeShow: -> (=>
            date = value.get().split '-'
            $(@).datepicker 'option', 'defaultDate', new Date(date[1], (parseFloat(date[0])-1), 1)
          )() if value.get()?
          onClose: (dateText, instance) ->
            $dp = $('#ui-datepicker-div')
            $input = instance.input
            month = $dp.find('.ui-datepicker-month :selected').val()
            year = $dp.find('.ui-datepicker-year :selected').val()
            $input.val $.datepicker.formatDate(dpOpts.dateFormat, new Date(year, month, 1))
            $input.trigger 'change'
      )() if opts.monthOnly

      div {class: 'input-group'}, [
        div {
          class: 'input-group-addon',
          click: -> openDp(@)
        }, [
          i {class: 'fa fa-calendar', click: -> openDp(@)}
        ]

        @input attr, placeholder, value, '', _.extend {
          init: -> @datepicker dpOpts
        }, opts
      ]