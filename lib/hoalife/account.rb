# frozen_string_literal: true

# :nodoc
class HOALife::Account < HOALife::Resource
  include HOALife::Resources::Persistable

  self.base_path = '/accounts'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'parent' => { 'data' => { 'id' => parent_id } }
    )

    h
  end
end
