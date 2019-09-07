# frozen_string_literal: true

require 'test_helper'

class HOALife::ViolationTest < HOALifeBaseTest
  def test_as_json
    instance = HOALife::Violation.new(
      'street_1' => 'foo', ccr_violation_type_id: 1,
      property_id: 2, inspector_email: 'foo'
    )

    result = {
      'data' => {
        'attributes' => {
          street_1: 'foo', ccr_violation_type_id: 1,
          property_id: 2, inspector_email: 'foo'
        },
        'relationships' => {
          'property' => { 'data' => { 'id' => 2 } },
          'ccr_violation_type' => { 'data' => { 'id' => 1 } },
          'inspector' => { 'data' => { 'email' => 'foo' } }
        }
      }
    }

    assert_equal result, instance.as_json
  end
end
