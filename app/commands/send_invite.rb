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
    invitation = create_invitation
    email_invitation if invitation && invitation.valid?
  end

  private
    def create_invitation
      invitation = @sender.sent_invites.create(
        email: @email,
        list: @list,
        recipient: @recipient
      )
      if invitation.persisted?
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
