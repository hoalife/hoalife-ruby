# frozen_string_literal: true

require 'test_helper'

class HOALife::Resources::PersistableTest < HOALifeBaseTest
  def setup
    @object = Class.new(HOALife::Resource)
    @object.include(HOALife::Resources::Persistable)
    @object.base_path = '/foo'
  end

  def test_create
    @object.stub(:new, OpenStruct.new(save: true)) do
      assert @object.create(foo: 'bar')
    end
  end

  def test_save_successful_create_new_resource
    instance = @object.new(name: 'Bob')
    response_json = {
      'data' => { 'attributes' => { 'name' => 'Bob', 'id' => 3 } }
    }

    response_mock = Minitest::Mock.new
    response_mock.expect(:json, response_json)
    url = HOALife.api_base + '/foo'

    HOALife::Client::Post.stub(:new, response_mock, [url]) do
      instance.save
      refute_nil instance.id
    end
  end

  def test_save_successful_update_new_resource
    instance = @object.new(name: 'Ed', id: 3)
    response_json = {
      'data' => { 'attributes' => { 'name' => 'Bob', 'id' => 3 } }
    }

    response_mock = Minitest::Mock.new
    response_mock.expect(:json, response_json)
    url = HOALife.api_base + '/foo/3'

    HOALife::Client::Put.stub(:new, response_mock, [url]) do
      instance.save
      assert_equal 'Bob', instance.name
    end
  end

  def test_destroy_successful
    instance = @object.new(name: 'Ed', id: 3)

    response_mock = Minitest::Mock.new
    response_mock.expect(:status, 202)
    url = HOALife.api_base + '/foo/3'

    HOALife::Client::Delete.stub(:new, response_mock, [url]) do
      assert instance.destroy
    end
  end

  def test_destroy_failure
    instance = @object.new(name: 'Ed', id: 3)

    response_mock = Minitest::Mock.new
    response_mock.expect(:status, 400)
    url = HOALife.api_base + '/foo/3'

    HOALife::Client::Delete.stub(:new, response_mock, [url]) do
      refute instance.destroy
    end
  end

  def test_save_resets_errors
    instance = @object.new(errors: true)

    instance.stub(:create!, true) do
      assert instance.save
    end
  end

  def test_save_create_failure
    instance = @object.new(errors: nil)

    errors = { 'data' => { 'attributes' => { 'foo': 'is nil' } } }
    request_blk = proc { raise HOALife::BadRequestError.new(200, nil, errors) }

    instance.stub(:make_request!, request_blk) do
      refute instance.save
    end
  end

  def test_save_update_failure
    instance = @object.new(errors: nil)

    errors = { 'data' => { 'attributes' => { 'foo': 'is nil' } } }
    request_blk = proc { raise HOALife::BadRequestError.new(200, nil, errors) }

    instance.stub(:make_request!, request_blk) do
      refute instance.save && instance.errors.nil?
    end
  end
end
