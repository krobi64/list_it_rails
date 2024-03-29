module ListItError
  class Error < StandardError; end

  class UnauthorizedUser < Error; end

  class ListNotFound < Error; end

  class InvitationNotFound < Error; end

  class InvalidListMembers < Error; end
end
