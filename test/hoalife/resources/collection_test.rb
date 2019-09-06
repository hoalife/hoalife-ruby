# frozen_string_literal: true

require 'test_helper'

class HOALife::Resources::CollectionTest < HOALifeBaseTest
  def setup
    @url      = 'http://example.com/foo?id=3'
    @instance = HOALife::Resources::Collection.new(@url)
  end

  def response_json
    @response_json ||= {
      'meta' => { 'total_pages' => 2, 'current_page' => 1, 'total' => 42 },
      'links' => { 'next' => @url + '&page=2' },
      'data' => [{ 'attributes' => { 'name' => 'Bob', 'id' => 3 } }]
    }
  end

  def stub_get(&blk)
    response_mock = Minitest::Mock.new
    response_mock.expect(:json, response_json)
    response_mock.expect(:json, response_json)
    response_mock.expect(:json, response_json)

    HOALife::Client::Get.stub(:new, response_mock, [@url]) do
      blk.call
    end
  end

  def test_where_returns_new_instance
    refute_equal @instance, @instance.where(bar: 'foo')
  end

  def test_where_adds_param
    new_url = @url + '&bar=foo'
    assert_equal new_url, @instance.where(bar: 'foo').url
  end

  def test_where_replaces_param
    new_url = @url.gsub('3', '4')
    assert_equal new_url, @instance.where(id: 4).url
  end

  def test_order
    new_url = @url + '&order=foo&order_dir=desc'
    assert_equal new_url, @instance.order(:foo, :desc).url
  end

  def test_reload
    stub_get do
      @instance.first
    end

    assert_changes -> { @instance.reload },
                   -> { @instance.instance_variable_get(:@data) }
  end

  def test_total
    stub_get do
      assert_equal 42, @instance.total
    end
  end

  def test_total_pages
    stub_get do
      assert_equal 2, @instance.total_pages
    end
  end

  def test_current_page
    stub_get do
      assert_equal 1, @instance.current_page
    end
  end

  def test_first
    resource = HOALife::Resource.new(response_json.dig('data').first)

    stub_get do
      assert_equal resource, @instance.first
    end
  end

  def test_all
    resources = []
    next_url = response_json.dig('links', 'next')
    next_resp = OpenStruct.new(all: [true])

    stub_get do
      HOALife::Resources::Collection.stub(:new, next_resp, [next_url]) do
        resources = @instance.all
      end
    end

    assert_equal 2, resources.size
  end

  def test_last
    @instance.stub(:all, [true]) do
      assert_equal true, @instance.last
    end
  end
end
