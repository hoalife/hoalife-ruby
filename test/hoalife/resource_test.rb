# frozen_string_literal: true

require 'test_helper'

class HOALife::ResourceTest < HOALifeBaseTest
  class HOALife::FakeResource < HOALife::Resource
    self.base_path = '/fake_resource'
  end

  def test_new_undefined_type
    assert_raises HOALife::UndefinedResourceError do
      HOALife::Resource.new('type' => 'foo')
    end
  end

  def test_new_returns_resource
    instance = HOALife::Resource.new(
      'type' => 'fake_resource', 'attributes' => { 'name' => 'foo' }
    )

    assert_instance_of(HOALife::FakeResource, instance)
  end

  def test_returns_self_without_type
    instance = HOALife::FakeResource.new(
      'name' => 'foo'
    )

    assert_instance_of(HOALife::FakeResource, instance)
  end

  def test_delegates_methods_to_resource_collection
    del_methods = %i[
      all first last where order total_pages current_page
      total count size reload
    ]

    collection_mock = Minitest::Mock.new
    del_methods.each { |del_method| collection_mock.expect(del_method, true) }

    HOALife::FakeResource.stub(:resource_collection, collection_mock) do
      sssshhh do
        del_methods.each { |del_method| HOALife::FakeResource.send(del_method) }
      end
    end

    collection_mock.verify
  end

  def test_time_is_parsed
    instance = HOALife::FakeResource.new(
      'created_at' => '2019-07-30T21:16:44.624Z'
    )

    assert_instance_of(Time, instance.created_at)
  end

  def test_as_json
    instance = HOALife::FakeResource.new(
      'name' => 'foo'
    )

    result = {
      'data' => {
        'attributes' => { :name => 'foo' },
        'relationships' => {}
      }
    }

    assert_equal result, instance.as_json
  end

  def test_to_json
    instance = HOALife::FakeResource.new(
      'name' => 'foo'
    )

    result = {
      'data' => {
        'attributes' => { :name => 'foo' },
        'relationships' => {}
      }
    }

    assert_equal JSON.generate(result), instance.to_json
  end
end
