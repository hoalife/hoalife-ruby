# frozen_string_literal: true

# A collection of resources
# Usually returned by an index endpoint
class HOALife::Resources::Collection
  include HOALife::Resources::Requestable

  attr_reader :url

  def initialize(url)
    @url = url
    @meta = {}
    @links = {}
  end

  # Return all pages
  def all
    all_resources = resources

    if @meta['current_page'] < @meta['total_pages']
      all_resources += self.class.new(@links['next']).all
    end

    all_resources
  end

  # Just return the first result
  def first
    if resources.is_a?(Array)
      resources.first
    else
      resources
    end
  end

  # Just return the last result
  def last
    all.last
  end

  # Add query parameters to the URL
  def where(params = {})
    self.class.new add_params_to_url!(params)
  end

  def order(col, dir = :asc)
    safe_dir = dir.to_s.downcase == 'desc' ? 'desc' : 'asc'
    self.class.new add_params_to_url!(order: col, order_dir: safe_dir)
  end

  def total_pages
    data

    @meta['total_pages']
  end

  def current_page
    data

    @meta['current_page']
  end

  def total
    data

    @meta['total']
  end
  alias count total
  alias size total

  def reload
    @data = nil

    self
  end

  private

  def request!
    make_request! do
      response = HOALife::Client::Get.new(@url)

      @meta  = response.json['meta']
      @links = response.json['links']

      response
    end
  end

  def add_params_to_url!(new_params)
    uri = URI(@url)
    exisiting_params = Hash[URI.decode_www_form(uri.query || '')]
    new_params.each { |k, v| exisiting_params[k.to_s] = v }
    uri.query = URI.encode_www_form(exisiting_params)

    uri.to_s
  end

  def data
    @data ||= request!.json['data']
  end

  def resources
    if data.is_a?(Array)
      # array of resource objects for each instance
      data.collect { |instance| HOALife::Resource.new(instance) }
    else
      # return a single resource
      HOALife::Resource.new(data)
    end
  end
end
