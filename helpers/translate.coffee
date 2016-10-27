'use strict'

define (require) ->
  Phos = Helpers: {}

  ###
  Translation helper
  ###
  class Phos.Helpers.Translate

    @.t = (key) -> I18n.t(key)

    @.common = (key) -> I18n.t("common.#{key}")

    @.address = (key) -> I18n.t("common.address.#{key}")

    @.contact = (key) -> I18n.t("common.contact.#{key}")

    @.emDevise = (key) -> I18n.t("devise.registrations.employer.#{key}")

    @.employer = (key) -> I18n.t("employer.#{key}")

    @.caDevise = (key) -> I18n.t("devise.registrations.candidate.#{key}")

    @.candidate = (key) -> I18n.t("candidate.#{key}")