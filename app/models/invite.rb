class Invite < ApplicationRecord
  before_create :generate_token
  belongs_to :list
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  private
    def generate_token
      self.token = SecureRandom.hex(16)
    end
end
