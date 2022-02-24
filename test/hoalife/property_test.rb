# frozen_string_literal: true

require 'test_helper'

class HOALife::PropertyTest < HOALifeBaseTest
  def method_as_array_passed_array(method_name)
    instance = HOALife::Property.new(
      method_name => %w[foo bar], account_id: 1
    )

    assert_equal %w[foo bar], instance.send(method_name)
  end

  def method_as_array_passed_string(method_name)
    instance = HOALife::Property.new(
      method_name => " foo , bar ", account_id: 1
    )

    assert_equal %w[foo bar], instance.send(method_name)
  end

  def method_as_array_passed_nil(method_name)
    instance = HOALife::Property.new(
      method_name => nil, account_id: 1
    )

    assert_equal [], instance.send(method_name)
  end

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

  def test_emails_setter_passed_array
    method_as_array_passed_array :emails
  end

  def test_phone_numbers_setter_passed_array
    method_as_array_passed_array :phone_numbers
  end

  def test_emails_setter_passed_string
    method_as_array_passed_string :emails
  end

  def test_phone_numbers_setter_passed_string
    method_as_array_passed_string :phone_numbers
  end

  def test_emails_setter_passed_nil
    method_as_array_passed_nil :emails
  end

  def test_phone_numbers_setter_passed_nil
    method_as_array_passed_nil :phone_numbers
  end
end
