# frozen_string_literal: true

module HOALife
  module Resources
    # Wrap an attribute in an object
    module HasNestedObject
      extend HOALife::Concern

      class_methods do
        attr_reader :has_nested_object

        def has_nested_object(key, class_name)
          @has_nested_object ||= {}

          @has_nested_object[key] = class_name

          add_nested_object_methods!(key, class_name)
        end

        private

        def add_nested_object_methods!(key, class_name)
          define_method key do
            raw_value = @obj[key.to_s]

            if raw_value.is_a?(Array)
              raw_value.collect do |value|
                Object.const_get("HOALife::#{class_name}").new(value)
              end
            elsif raw_value.is_a?(Hash)
              Object.const_get("HOALife::#{class_name}").new(raw_value)
            else
              super
            end

          rescue NameError, ArgumentError
            raise UndefinedResourceError, "HOALife::#{class_name} is not defined"
          end
        end
      end
    end
  end
end
