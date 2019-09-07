# frozen_string_literal: true

require 'test_helper'

class HOALife::PropertyTest < HOALifeBaseTest
  def test_as_json
    instance = HOALife::Property.new(
      'street_1' => 'foo', account_id: 1
    )

    result = {
      'data' => {
        'attributes' => { street_1: 'foo', account_id: 1 },
        'relationships' => { 'account' => { 'data' => { 'id' => 1 } } }
      }
    }

    assert_equal result, instance.as_json
  end
end
