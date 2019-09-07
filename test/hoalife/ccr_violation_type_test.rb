# frozen_string_literal: true

require 'test_helper'

class HOALife::CCRViolationTypeTest < HOALifeBaseTest
  def test_as_json
    instance = HOALife::CCRViolationType.new(
      'street_1' => 'foo', ccr_article_id: 1
    )

    result = {
      'data' => {
        'attributes' => { street_1: 'foo', ccr_article_id: 1 },
        'relationships' => { 'ccr_article' => { 'data' => { 'id' => 1 } } }
      }
    }

    assert_equal result, instance.as_json
  end
end
