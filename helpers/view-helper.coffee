'use strict'

define (require) ->
  Fulcrum = Helpers: {}

  ###
  ViewHelper is used for handling common updates to the view
  ###
  class Fulcrum.Helpers.ViewHelper

    ###
    Constructor
    ###
    constructor: ->
      @

    ###
    Display a message to the user after a jquery ajax method has completed.

    @method responseLabel
    @param element {JQueryElement} The jQuery element to display the message on
    @param xhr {Object} The AJAX request
    ###
    @.responseLabel = (element, xhr) ->
      switch typeof xhr
        when 'object' # Valid responses
          response = xhr.response
          cssClass = (unless response.error.status then 'label-success' else 'label-important')
          message = (unless response.error.status then response.message else response.error.message)
        when 'string' # Server error responses (likely anyway)
          cssClass = 'label-important'
          message = xhr
        else # All other responses
          cssClass = 'label-important'
          message = ''
      element.addClass(cssClass).text(message).fadeIn(300, ->
        element.delay(500).fadeOut(300, -> element.removeClass(cssClass))
      )


    ###
    Issue a click event on the provided element within the scope

    @method click
    @param scope {JQueryElement/DOMElement} The scope
    @param element {String} The id or class of the element to issue the click event on
    ###
    @.click = (scope, element) ->
      clicker = $(scope).find(element)
      clicker.trigger('click')  unless clicker.is(':disabled')


    ###
    Override the form onSubmit event

    @method formSubmit
    @param scope {JQueryElement/DOMElement} The scope
    @param form {String} The id or class of the form
    @param button {String} The id or class of the submit button
    ###
    @.formSubmit = (scope, form, button) ->
      $(scope).find(form).on
        submit: (event) =>
          event.preventDefault()
          @.click(scope, button)