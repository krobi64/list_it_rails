class ItemVerifier
  attr_reader :verifier

  def self.instance
    ItemVerifier.new
  end

  def generate(message)
    verifier.generate(message, purpose: :item_sort)
  end

  def valid_message?(signed_message)
    verifier.valid_message?(signed_message)
  end

  def verify(signed_message)
    verifier.verify(signed_message, purpose: :item_sort)
  end

  def verified(signed_message)
    verifier.verified(signed_message)
  end

  private

    def initialize
      secret = 'ToBeReplacedWithVault'
      @verifier ||= ActiveSupport::MessageVerifier.new(secret, digest: 'SHA512', serializer: JSON )
    end
end
