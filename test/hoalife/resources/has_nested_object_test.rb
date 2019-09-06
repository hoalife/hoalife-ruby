# frozen_string_literal: true

require 'test_helper'

class HOALife::Resources::HasNestedObjectTest < HOALifeBaseTest
  def setup
    @object = Class.new(OpenStruct)
    @object.include(HOALife::Resources::HasNestedObject)
  end

  def test_undefined_resource
    @object.has_nested_object(:people, 'Foos')
    instance = @object.new(people: [])

    assert_raises HOALife::UndefinedResourceError do
      instance.people
    end
  end

  def test_array_of_resources
    @object.has_nested_object(:people, 'User')
    instance = @object.new(people: [{ name: 'Bob' }])

    assert_equal [HOALife::User.new(name: 'Bob')], instance.people
  end

  def test_single_resource
    @object.has_nested_object(:people, 'User')
    instance = @object.new(people: { name: 'Bob' })

    assert_equal HOALife::User.new(name: 'Bob'), instance.people
  end

  def test_not_a_resource
    @object.has_nested_object(:people, 'User')
    instance = @object.new(people: 'thing')

    assert_equal 'thing', instance.people
  end
end
