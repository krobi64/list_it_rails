# frozen_string_literal: true

module Messages
  DUPLICATE_EMAIL = I18n.t('activerecord.models.user.errors.duplicate_email')
  EXPIRED_TOKEN = I18n.t('activemodel.errors.models.authorize_api_request.attributes.token.expired')
  INVALID_CREDENTIALS = I18n.t('activemodel.errors.models.authenticate_user.failure')
  INVALID_EMAIL_ADDRESS = I18n.t('activemodel.errors.invalid_email')
  INVALID_INVITATION_TOKEN = I18n.t('activemodel.errors.models.accept_invite.attributes.token')
  INVALID_PARAMETER = I18n.t('actioncontroller.errors.list.invalid_parameters')
  INVALID_PASSWORD = I18n.t('activerecord.models.user.errors.password')
  INVALID_TOKEN = I18n.t('activemodel.errors.models.authorize_api_request.attributes.token.invalid')
  INVALID_ITEMS = I18n.t('activerecord.models.item.errors.invalid_items')
  INVITATION_NOT_FOUND = I18n.t('activerecord.models.invite.errors.not_found')
  INVITATION_SENT=I18n.t('activemodel.success.models.send_invite')
  ITEM_NAME_BLANK = I18n.t('activerecord.models.item.errors.name')
  ITEM_NOT_FOUND = I18n.t('activerecord.models.item.errors.not_found')
  LIST_NAME_BLANK = I18n.t('activerecord.models.list.errors.name')
  LIST_NOT_FOUND = I18n.t('activerecord.models.list.errors.not_found')
  MISSING_TOKEN = I18n.t('activemodel.errors.models.authorize_api_request.attributes.token.missing')
  NOT_FOUND = I18n.t('routes.errors.not_found')
  USER_NOT_FOUND = I18n.t('activerecord.models.user.errors.not_found')
end
