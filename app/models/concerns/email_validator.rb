class EmailValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:email, I18n.t('activemodel.errors.invalid_email')) unless Truemail.valid?(record.email, with: :regex)
  end
end
