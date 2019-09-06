# frozen_string_literal: true

require 'test_helper'

class HOALife::Resources::HasNestedResourcesTest < HOALifeBaseTest
  def setup
    @object = Class.new(OpenStruct)
    @object.include(HOALife::Resources::HasNestedResources)
    @object.has_nested(:things)
  end

  def test_isnt_array
    instance = @object.new(things: true)

    assert_instance_of Array, instance.things
  end

  def test_returns_collection_of_resources
    instance = @object.new(
      things: [
        { 'link' => 'foo' }
      ]
    )

    foo_collection_mock = Minitest::Mock.new
    foo_collection_mock.expect(:all, true)
    HOALife::Resources::Collection.stub(:new, foo_collection_mock, ['foo']) do
      assert_equal [true], instance.things
    end

    foo_collection_mock.verify
  end
end
