'use strict'

define (require) ->
  _           = require 'underscore'
  Phos        = Helpers: {}
  Phos.Helpers.Routes = require './routes'

  ###
  HTML is used to help with the View
  ###
  class Phos.Helpers.HTML

    ###
    Returns the content of a meta tag

    @method meta
    @param name {String}
    ###
    @.meta = (name) -> $("meta[name=#{name}]").attr('content')

    ###
    Hide/Show the preloader

    @method preloader
    @param type {String} The type of preloader
    @param visible {Boolean} Hide / show the preloader
    ###
    @.preloader = (type = 'shell', visible = false) ->
      shell   = $('#shell-preloader')
      module  = $('#module-preloader')

      switch type
        when 'shell'
          if visible then shell.fadeIn() else shell.hide()
        when 'module'
          if visible then module.fadeIn() else module.hide()
        else
          null


    ###
    Attach css for a component

    @method scopedCSS
    @param scope {JQueryElement}
    @param styleText {String}
    ###
    @.scopedCSS = (scope, styleText) ->
      $(scope).prepend $("<style type='text/css' scoped='scoped'>#{styleText}</style>")


    ###
    Create a template from backend rendered html already in the DOM

    @method templateFromDOM
    @param id {String} The id for the template
    @return {String}
    ###
    @.templateFromDOM = (id) -> "<span>#{$(id).remove()[0]?.outerHTML}</span>"


    ###
    Retrieve json object of labels from the DOM for view rendering

    @method labels
    @oaram scope (jQueryElement} The scope of the dom to search
    @param el {String} The class or id
    @return {JSON}
    ###
    @.labels = (scope, el) -> scope.find(el).data('labels')

    ###
    Display Modal for xhr errors

    @method xhrError
    @param xhr {Object}
    ###
    @.xhrError = (xhr) ->
      if xhr.status not in [400, 401]
        text = (->
          if xhr.responseJSON?.error?
            xhr.responseJSON.error
          else if xhr.responseJSON?.errors?
            _.map(xhr.responseJSON.errors, (str) -> "<p>#{str}</p>").join('')
          else
            ((str) ->
              if str.length is 0 then xhr.responseText else str
            )(xhr.responseText.substr(0, xhr.responseText.indexOf("\n")))
        )()
        status = "#{xhr.statusText} #{if xhr.status then xhr.status else ""}"
        HTML.modal 'common.error', "Error - #{status}: #{text}", 'common.ok'

    ###
    Load a generic Modal.

    @method modal
    @param title {String} The I18n key for the title.
    @param text {String / Array} The body. Either plain text or array of I18n keys.
    @param button {String / Array} The I18n key(s) for the button(s).
    ###
    @.modal = (title, text, button) ->
      modal   = $ '#js-modal'
      body    = modal.find '.modal-body'
      btnGrey = modal.find '.btn-default'
      btnPrim = modal.find '.btn-primary'

      btnPrim.off 'click'
      btnPrim.on 'click': -> modal.modal 'hide'

      modal.find('.modal-title').text I18n.t(title)

      body.html if _.isArray text
         _.map(text, (str) -> "<p>#{I18n.t(str)}</p>").join('')
      else
        "<p>#{text}</p>"

      if _.isArray button
        btnGrey.show()
        btnGrey.text I18n.t(_.first(button))
        btnPrim.text I18n.t(_.last(button))
      else
        btnGrey.hide()
        btnPrim.text I18n.t(button)

      modal.modal()
      modal.modal 'show'

    ###
    Session inactive modal.

    @method sessionInactive
    ###
    @.sessionInactive = ->
      modal = $ '#session-inactive'
      modal.modal()
      modal.find('.btn-primary').on click: -> window.location = Phos.Helpers.Routes.user_session_path()

