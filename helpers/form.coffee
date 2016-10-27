'use strict'

define (require) ->
  _     = require 'underscore'
  ko    = require 'knockout'
  Phos  = Helpers: {}

  class Phos.Helpers.Form

    constructor: (@$el) -> @btnGroup()

    ###
    Get form token
    @method getToken
    @return {Object}
    ###
    @.getToken = ->
      csrfToken: $('meta[name="csrf-token"]').attr 'content'
      csrfParam: $('meta[name="csrf-param"]').attr 'content'

    ###
    Default options for select2
    @method select2
    @return {Object}
    ###
    @.select2 = (options = []) ->
      selectOptions =
        closeOnSelect:            false if 'multiple' in options
        allowClear:               true if 'allowClear' in options
        removeFirst:              false if 'noRemove' in options
        minimumResultsForSearch:  -1 if 'noSearch' in options

      _.extend(
        selectOptions,
        'select2-open': -> $(@).select2('close')
      ) if 'disabled' in options

      selectOptions

    ###
    Default field format for phone
    @method phone
    @return {String}
    ###
    @.phone = -> '(999) 999-9999'

    ###
    Default field format for postal/zip code
    @method postal
    @return {String}
    ###
    @.postal = -> '99999'

    @Hours:

      ###
      Update the hour observables assigned to the view
      @method updateView
      @param array {Array[Array]} The new array value
      @param observableArray {ObservableArray} The observable array assigned to the view
      ###
      updateViewHours: (array, observableArray) ->
        _.each array, (hours, index) ->
          observableArray()[index]()[0] hours[0]
          observableArray()[index]()[1] hours[1]

      ###
      Update the closed observables assigned to the view
      @method updateViewClosed
      @param array {Array} The new array value
      @param observableArray {ObservableArray} The observable array assigned to the view
      ###
      updateViewClosed: (array, observableArray) ->
        _.each array, (closed, index) -> observableArray()[index]().closed closed

      ###
      Create hour
      @method createHour
      @param attrObs {Observable}
      @param hours {Array}
      @param index {Integer}
      @param ampm {Integer}
      @return {Observable}
      ###
      createHour: (attrObs, hours, index, ampm) ->
        # Create hours observable
        hours[ampm] = ko.observable hours[ampm]
        # Subscribe to observable changes to update the view model
        hours[ampm].subscribe (value) -> attrObs()[index][ampm] = value
        hours[ampm]

      ###
      Create closed
      @method createClosed
      @param hours {Observable}
      @param vm {Object}
      @param index {Integer}
      @return {Object}
      ###
      createClosed: (hours, vm, index) ->
        # Set closed observable on the hours object
        hours.closed = ko.observable vm.hours_closed()[index]
        # Subscribe to changes on the closed observable to update the viewmodel
        hours.closed.subscribe (value) -> vm.hours_closed()[index] = value
        hours

      ###
      Create hours
      @method createHours
      @param vm {Object}
      @return {Observable}
      ###
      createHours: (vm) ->
        ko.observableArray(_.map(vm.hours(), (hours, index) ->
          # Create array of 2 observables for AM and PM open / close times
          hours = [Form.Hours.createHour(vm.hours, _.clone(hours), index, 0), Form.Hours.createHour(vm.hours, _.clone(hours), index, 1)]
          # Set the model attribute for model reference on the hours array object
          hours.model = vm.model
          # Create the closed attribute
          hours = Form.Hours.createClosed hours, vm, index
          # Return an observable array for the hours
          ko.observableArray hours
        ))



    ###
    Create a locality provider (ajax)
    @method localityProvider
    @param viewModel {Object} The knockout view model (requires observable attributes for locality_id and state)
    @param getState {Function} The ajax method handler
    @return {Array[Object]}
    ###
    @.localityProvider = (viewModel, getState)  ->
      states = ko.observableArray()
      localities = ko.observableArray()

      localities.subscribe (value, event) =>
        if value?.length <= 0
          states []
        else
          locality = _.last(value)
          viewModel.locality_id locality.id

          getState(locality.state).done (result) =>
            if result?.length <= 0
              states []
            else
              states result
              id = _.first(result).id
              viewModel.state id

      [states, localities]

    ###
    Create default knockout bindings for address markup
    @method bindAddress
    @param prefix {String} The prefix for the elements class
    @param getLocality {Function} The ajax provider for the zip code field to populate city and state
    @param collections {ObservableArray}
    @return {Object}
    ###
    @.bindAddress = (prefix, getLocality, collections) ->

      isObservable = -> ko.isObservable collections

      getCollection = (type, index) ->
        if isObservable()
          collections()[index][type]
        else
          collections[type]

      bindings = {}

      bindings[".#{prefix}_street_address"] = (d) ->
        attrByIndex: isObservable()
        value: d.street_address
        error: 'street_address'

      bindings[".#{prefix}_postal_code"] = (d, context) ->
        attrByIndex: isObservable()
        value: d.postal_code
        error: 'postal_code'
        localityLookup:
          value: d.postal_code
          localities: getCollection 'localities', context.$index?()
          method: getLocality
        valueUpdate: 'keyup'
        jqueryui:
          widget: 'mask'
          options: Phos.Helpers.Form.postal()

      bindings[".#{prefix}_locality_id"] = (d, context) =>
        attrByIndex: isObservable()
        jqueryui:
          widget: 'select2'
          options: @.select2 ['noSearch']
          events: @.select2 ['disabled']
        options: getCollection 'localities', context.$index?()
        value: d.locality_id
        selectedOption: d.locality_id
        optionsText: 'name'
        optionsValue: 'id'
        optionsCaption: true

      bindings[".#{prefix}_state"] = (d, context) =>
        attrByIndex: isObservable()
        jqueryui:
          widget: 'select2'
          options: @.select2 ['noSearch']
          events: @.select2 ['disabled']
        options: getCollection 'states', context.$index?()
        value: d.state
        selectedOption: d.state
        optionsText: 'label'
        optionsValue: 'id'
        optionsCaption: true

      bindings

    ###
    Default datepicker bindings
    @method datepicker
    @param options {Object}
    ###
    datepicker: (options = {}) ->
      $el = @$el.find options.el or 'input[type="text"].date-control, input[type="text"].month-control'
      delete options.el  if options.el
      sunday = options.sunday

      datepicker = (e, options) ->
        $in    = $ e
        data  = _.extend $in.data('datepicker') or {}, options

        if $in.hasClass('month-control')
          val = $in.val().split('-')
          $in.val "#{val[1]}-#{val[0]}" if val.length is 3
          data = _.extend data,
            beforeShow: (ct, inst) ->
              $ct = $ ct
              $dp = inst.dpDiv
              $dp.addClass('ui-month-datepicker')

              val   = $ct.val().split('-')
              date  = if val.length is 2 then moment "#{val[0]}-01-#{val[1]}" else null

              forceDate = ->
                setTimeout(->
                  $dp.find('.ui-datepicker-month').val parseFloat(date.format('M')) - 1
                  $dp.find('.ui-datepicker-year').val date.format('YYYY')
                  $ct.datepicker 'setDate', date.toDate()
                , 250)

              forceDate() if date?

            onClose: (dateText, inst) ->
              $dp   = inst.dpDiv
              month = $dp.find('.ui-datepicker-month :selected').val()
              year  = $dp.find('.ui-datepicker-year :selected').val()
              $(@).datepicker 'setDate', new Date(year, month, 1)
              setTimeout(->
                inst.dpDiv.removeClass('ui-month-datepicker')
              , 500)

        $in.datepicker _.extend({ dateFormat: 'yy-mm-dd', minDate: 0 }, data)
        $in.datepicker 'setDate', data.setDate  if data.setDate
        $in

      # No Sunday
      noSunday = (date) ->
        date.add 'days', 1  if date.day() is 0
        date

      options = _.extend(
        setDate:        noSunday(moment()).toDate()
        beforeShowDay:  (date) -> [moment(date).day() isnt 0, date]
      ,
        options
      ) unless sunday is false

      $el.each (i, e) -> datepicker e, options