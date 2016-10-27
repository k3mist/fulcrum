'use strict'

define (require) ->
  Logger  = require 'core/helpers/logger'
  tr      = require 'core/helpers/translate'

  bind = rx.bind

  ###
  HTML is used to help with the View
  ###
  class Form

    logger = new Logger()

    # Form container
    container: (rxHtml, title, intro, cols = 10) ->
      section {class: 'wrapper-sm bg-highlight'}, [
        div {class: 'container'}, [
          div {class: 'row'}, [
            div {class: "col-md-#{cols} col-md-offset-1"}, [
              div {class: 'widget widget-dashed padding-md bg-light'}, [
                h2 {}, title
                div {class: 'alert alert-info'}, intro
                div {class: 'text-danger help-block'}, tr.common('mandatory_label')
                form {role: 'form', class: 'form', multipart: 'true'}, rxHtml
              ]
            ]
          ]
        ]
      ]

    # Form group container
    group: ($label, $field, options = {}) ->
      styles = "clearfix"
      styles = "#{styles} #{options.class}" if options.class?
      styles = "#{styles} col-sm-7" unless options.class?.match(/col\-/)
      options.class = styles
      div {class: 'form-group'}, [
        $label
        div {class: styles}, $field
      ]

    # Help block
    help: (text) ->
      div {class: 'help-block no-margin-bottom'}, text

