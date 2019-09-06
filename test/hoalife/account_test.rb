# frozen_string_literal: true

require 'test_helper'

class HOALife::AccountTest < HOALifeBaseTest
  def test_as_json
    instance = HOALife::Account.new(
      'name' => 'foo', parent_id: 1
    )

    result = {
      'data' => {
        'attributes' => { name: 'foo', parent_id: 1 },
        'relationships' => { 'parent' => { 'data' => { 'id' => 1 } } }
      }
    }

    assert_equal result, instance.as_json
  end
end
