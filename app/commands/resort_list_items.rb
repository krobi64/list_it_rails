class ResortListItems
  prepend SimpleCommand

  def initialize(current_list, list_item_ary)
    @current_list = current_list
    @list_item_ary = list_item_ary
    raise ListItError::InvalidListMembers.new unless valid?
  end

  def call
    list_item_ary.each_with_index do |token, i|
      next unless token.present?
      item = retrieve_item(token)
      item.update_attribute(:order, i) if item.order != i
    end
  end

  private
    attr_reader :list_item_ary, :current_list

    def retrieve_item(token)
      id = verifier.verify(token).match(/Item(\d+)/)[1]
      current_list.items.find(id)
    end

    def verifier
      @verifier ||= ItemVerifier.instance
    end

    def valid?
      current_list.items.size == list_item_ary.size
    end
end
