'use strict'

define (require) ->
  _ = require('underscore')

  Fulcrum = {}
  Helpers = require('./helpers/_helpers_')

  ###
  ViewTemplate is used to render and localize the HTML templates for each
  individual component.
  ###
  class Fulcrum.ViewTemplate

    ###
    Constructor

    @param parent {JQueryElement} The parent DOM element for the template
    @param viewTemplate {String} The HTML markup
    @param nls {String} The locale for localization
    @param styleText {String} Any additional styling for the view. Only if neccessary.
    ###
    constructor: (parent, viewTemplate, nls, styleText) ->
      @createView parent, viewTemplate, nls, styleText


    ###
    Create a style tag on the head and attach the given text in to it as CSS.
    If a style tag exists with the given styleId, CSS text will be replaced.

    @method setStyleText
    @param styleId {String} uniqueId for the style tag
    @param styleText {String} CSS text as a string
    ###
    @.setStyleText = (styleId, styleText) ->
      Helpers.Styler.attachCssText styleId, styleText


    ###
    Create a css link tag on the head with the reference to the given href.
    If a link tag exists with the given linkId, href will be replaced.

    @method setStyleLink
    @param href {String} URL to the CSS file
    @param linkId {String} uniqueId for the link tag
    ###
    @.setStyleLink = (href, linkId) ->
      Helpers.Styler.attachCssLink href, linkId


    ###
    Returns the view id

    @method getViewId
    @return {String}
    ###
    getViewId: ->
      @viewId


    ###
    Returns the jQuery element of this component

    @method getJqueryElement
    @return {JQueryElement}
    ###
    getJQueryElement: ->
      @jQueryElement


    ###
    Returns the DOM element

    @method getDomElement
    @return {DOMElement}
    ###
    getDomElement: ->
      @jQueryElement.get 0


    ###
    Append the template to the parent container

    @param parent {DOMElement}
    ###
    appendTo: (parent) ->
      @jQueryElement.appendTo parent


    ###
    Remove the DOM element of this component from the DOM tree

    @method remove
    ###
    remove: ->
      @jQueryElement.remove()


    ###
    Hide the DOM element of this component in the DOM tree

    @method hide
    ###
    hide: ->
      @jQueryElement.hide()


    ###
    Show the DOM element of this component in the DOM tree

    @method show
    ###
    show: ->
      @polyfill()
      @jQueryElement.show()


    ###
    Fade in the DOM element of this component in the DOM tree

    @method fadeIn
    @param parent {JQueryElement}
    ###
    fadeIn: (parent) ->
      parent.css(
        opacity: 0
      ).animate
        opacity: 1
      ,
        duration: 300
      @show().css(
        opacity: 0
      ).animate
        opacity: 1
      ,
        duration: 300


    ###
    Append a preloader in the DOM tree for this component

    @method preloader
    @param element {DOMElement}
    ###
    preloader: (element) ->
      preloader = $('#scripts').find('.preloader').clone().removeClass('hidden').show()
      if element? and $(element).length > 0
        @getJQueryElement().find(element).append(preloader)
      else
        @getJQueryElement().append(preloader)


    ###
    Hide the preloader and fade in the DOM element of this component

    @method ready
    @param parent {JQueryElement}
    ###
    ready: (parent) ->
      preloader = parent.find('.preloader')
      $(preloader[0]).hide() if preloader.length > 0
      @fadeIn(parent)


    ###
    Polyfill for Internet Explorer

    @method polyfill
    ###
    polyfill: ->
      # Polyfill
      msie = navigator.userAgent.match(/MSIE/)
      opera = navigator.userAgent.match(/Opera/)
      @getJQueryElement().updatePolyfill()  if msie or opera


    ###
    Creates a localized view template and appends it to the parent container

    @method createView
    @param parent {JQueryElement} The parent DOM element for the template
    @param viewTemplate {String} The HTML markup
    @param nls {String} The locale for localization
    @param styleText {String} Any additional styling for the view. Only if neccessary.
    @return {DOMElement}
    ###
    createView: (parentElement, viewText, nls, styleText) ->

      #apply localization on the template
      viewText = if nls? then Helpers.Localizer.localize(viewText, nls) else viewText

      # create a random id for the child and create a new element
      @viewId = _.uniqueId(['module-container_'])
      @jQueryElement = $("<span id='#{@viewId}'>#{viewText}</span>")
      Helpers.Styler.attachScopedCss @jQueryElement, styleText

      #if parent is specified, lets attach the element to parent
      parentElement.append @jQueryElement  if parentElement
