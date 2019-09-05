# frozen_string_literal: true

# Wrap an attribute in an object
module HOALife::Resources::HasNestedObject
  extend HOALife::Concern

  class_methods do
    attr_reader :has_nested_object

    # rubocop:disable Naming/PredicateName
    def has_nested_object(key, class_name)
      @has_nested_object ||= {}

      @has_nested_object[key] = class_name

      add_nested_object_methods!(key, class_name)
    end
    # rubocop:enable Naming/PredicateName

    private

    # rubocop:disable Metrics/MethodLength
    def add_nested_object_methods!(key, class_name)
      define_method key do
        raw_value = @obj[key.to_s]

        begin
          klass = Object.const_get("HOALife::#{class_name}")
        rescue ArgumentError
          raise UndefinedResourceError, "HOALife::#{class_name} not defined"
        end

        if raw_value.is_a?(Array)
          raw_value.collect { |value| klass.new(value) }
        elsif raw_value.is_a?(Hash)
          klass.new(value)
        else
          super
        end
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
