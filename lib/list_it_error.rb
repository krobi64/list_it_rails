module ListItError
  class Error < StandardError
  end
  class UnauthorizedUser < Error
  end

  class ListNotFound < Error
  end
end
