class SendInvite
  prepend SimpleCommand
  include ActiveModel::Validations

  def initialize(email, list, sender, recipient = nil)
    @email = email
    @list = list
    @sender = sender
    @recipient = recipient
  end

  def call
    create_invitation
  end

  private
    attr_reader :email, :list, :sender, :recipient
    def create_invitation
      invitation = sender.sent_invites.create(
        email: email,
        list: list,
        recipient: recipient
      )
      if invitation.persisted?
        email_invitation
        return invitation
      else
        invitation.errors.each do |err|
          errors.add(err.attribute, err.type)
        end
        return nil
      end
    end

    def email_invitation
      # Add mailer here
      return true
    end
end
