'use strict'

define (require) ->
  Fulcrum = Helpers: {}

  ###
  Styler is used to attach css style sheets to the DOM (Document Object Model) and to attach css text to existing style sheets
  ###
  class Fulcrum.Helpers.Styler

    ###
    Creates a style link tag

    @param href {String} The link
    @param elementId {String} The id of the style link
    ###
    createCssLink = (href, elementId) ->
      link = document.createElement("link")
      link.id = elementId  if elementId
      link.type = "text/css"
      link.rel = "stylesheet"
      link.href = href
      document.getElementsByTagName("head")[0].appendChild link


    ###
    Attach a css link to the DOM

    @method attachCssLink
    @param css {Object}
    @param elementId {Object} Element ID
    ###
    @.attachCssLink = (href, elementId) ->
      if elementId
        link = document.getElementById(elementId)
        unless link
          createCssLink href, elementId
        else
          link.href = href
      else
        links = document.getElementsByTagName("link")
        i = 0

        while i < links.length
          #If we have already added this link, just ignore and return
          return  if links[i].href and (links[i].href.indexOf(href) isnt -1)
          i++
        createCssLink href


    ###
    Attach css text to an existing style sheet

    @method attachCssText
    @param elementId {Object} Element ID
    @param css {Object}
    ###
    @.attachCssText = (elementId, css) ->
      elem = document.getElementById(elementId)
      elem.parentNode.removeChild elem  if elem

      style = document.createElement("style")
      style.type = "text/css"
      style.setAttribute "id", elementId

      if style.styleSheet
        style.styleSheet.cssText = css
      else
        style.appendChild document.createTextNode(css)

      document.getElementsByTagName("head")[0].appendChild style


    ###
    Attach css for a component

    @method attachScopedCss
    @param scope {DOMElement}
    @param styleText {String}
    ###
    @.attachScopedCss = (scope, styleText) ->
      scope.prepend $("<style type='text/css' scoped='scoped'>#{styleText}</style>")  if styleText
