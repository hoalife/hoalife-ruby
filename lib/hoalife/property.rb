# frozen_string_literal: true

# :nodoc
class HOALife::Property < HOALife::Resource
  include HOALife::Resources::Persistable

  self.base_path = '/properties'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'account' => { 'data' => { 'id' => account_id } }
    )

    h
  end
end
