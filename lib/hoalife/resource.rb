# frozen_string_literal: true

require 'ostruct'
require 'json'
require 'time'
require 'forwardable'

# :nodoc
class HOALife::Resource < OpenStruct
  class << self
    extend Forwardable

    attr_accessor :base_path
    def_delegators :resource_collection, :all, :first, :last, :where, :order,
                   :total_pages, :current_page, :total, :count, :size, :reload

    def new(obj = {}, relationships = {})
      return super(obj, relationships) unless obj['type']

      camelized = HOALInflector.new.camelize(obj['type'], nil)

      begin
        klass = Object.const_get("HOALife::#{camelized}")
      rescue NameError
        raise UndefinedResourceError,
              "HOALife::#{camelized} is not defined"
      end

      klass.new(obj['attributes'], obj['relationships'])
    end

    def resource_collection
      @resource_collection ||= HOALife::Resources::Collection.new(
        HOALife.api_base + base_path
      )
    end

    def create(attrs = {})
      new(attrs).save
    end
  end

  def initialize(obj = {}, _relationships = {})
    @obj = cast_attrs(obj)

    super(obj)
  end

  def as_json
    h = {
      'data' => {
        'attributes' => {},
        'relationships' => {}
      }
    }

    each_pair do |k, _v|
      h['data']['attributes'][k] = send(k)
    end

    h
  end

  def to_json(*_args)
    JSON.generate as_json
  end

  private

  # rubocop:disable Style/RescueModifier
  def cast_attrs(obj)
    obj.each do |k, v|
      next unless k.match?(/_at$/)

      time = Time.parse(v) rescue nil
      obj[k] = time if time
    end
  end
  # rubocop:enable Style/RescueModifier
end
