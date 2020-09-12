# frozen_string_literal: true

# :nodoc
class HOALife::Properties::SupplementalMailingAddress < HOALife::Resource
  include HOALife::Resources::Persistable

  self.base_path = '/properties/supplemental_mailing_addresses'

  def as_json
    h = super

    h.dig('data', 'relationships').merge!(
      'property' => { 'data' => { 'id' => property_id } }
    )

    h
  end
end
