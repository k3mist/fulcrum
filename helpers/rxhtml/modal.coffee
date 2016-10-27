'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Modal

    logger = new Logger()

    # Modal container
    $container: $('#rx-modal')

    # Modal div
    div: (opts) ->
      div {class: 'modal fade'}, [
        div {class: 'modal-dialog'}, [
          div {class: 'modal-content'}, [
            div {class: 'modal-header'}, [
              h4 {class: 'modal-title'}, opts.title
            ]
            div {class: 'modal-body'}, opts.body
            div {class: 'modal-footer'}, _.compact([
              button {type: 'button', class: 'btn btn-default cancel'}, tr.common('cancel') if opts.cancel?
              button {type: 'button', class: 'btn btn-default ok'}, tr.common('ok')
            ])
          ]
        ]
      ]

    # Hide
    hide: (el) -> $(el).closest('.modal').modal('hide')

    ###
    Query

    A Modal that accepts as yes no answer
    @param opts {Object}
    @option fnOk {Function}
    @option fnCancel {Function}
    @option title {String}
    @option body {String}
    @option cancel {Boolean} Enable cancel button
    ###
    query: (opts) ->
      modal = @
      $el = modal.div(opts)
      fnOk = (event) -> modal.hide(@)
      fnCancel = (event) -> modal.hide(@)

      opts.fnOk = fnOk unless opts.fnOk?
      opts.fnCancel = fnCancel unless opts.fnCancel?

      $el.find('.cancel').on
        click: opts.fnCancel
      $el.find('.ok').on
        click: opts.fnOk

      modal.insert $el
      $el.modal('show')

    # Insert
    insert: (html) -> @$container.html(html)