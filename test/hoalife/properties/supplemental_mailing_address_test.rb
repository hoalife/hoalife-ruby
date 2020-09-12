# frozen_string_literal: true

require 'test_helper'

class HOALife::Properties::SupplementalMailingAddressTest < HOALifeBaseTest
  def test_as_json
    instance = HOALife::Properties::SupplementalMailingAddress.new(
      'mailing_street_1' => 'foo', property_id: 1
    )

    result = {
      'data' => {
        'attributes' => { mailing_street_1: 'foo', property_id: 1 },
        'relationships' => { 'property' => { 'data' => { 'id' => 1 } } }
      }
    }

    assert_equal result, instance.as_json
  end
end
