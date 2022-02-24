# frozen_string_literal: true

require 'ostruct'
require 'json'
require 'time'
require 'forwardable'

# :nodoc
class HOALife::Resource
  extend HOALife::Arrayable

  attr_reader :attrs

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
        raise HOALife::UndefinedResourceError,
              "HOALife::#{camelized} is not defined"
      end

      klass.new(obj['attributes'], obj['relationships'])
    end

    def resource_collection
      @resource_collection ||= HOALife::Resources::Collection.new(
        HOALife.api_base + base_path
      )
    end
  end

  def initialize(attrs = {}, _relationships = {})
    @attrs = {}

    cast_attrs(attrs.transform_keys(&:to_sym)).each do |k, v|
      send("#{k}=".to_sym, v)
    end
  end

  def as_json
    h = {
      'data' => {
        'attributes' => {},
        'relationships' => {}
      }
    }

    @attrs.each do |k, _v|
      h['data']['attributes'][k] = send(k)
    end

    h
  end

  def to_json(*_args)
    JSON.generate as_json
  end

  def method_missing(method_name, *args, &blk)
    if method_name.match(/\=$/)
      @attrs[method_name.to_s.gsub(/\=$/, "").to_sym] = args.first
    elsif @attrs.key?(method_name)
      @attrs[method_name]
    else
      super
    end
  end

  def respond_to?(method_name, include_private = false)
    !@attrs[method_name] ||
      method_name.match(/\=$/) ||
      super
  end

  def ==(other)
    @attrs == other.attrs
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
