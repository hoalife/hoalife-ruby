# frozen_string_literal: true

module HOALife
  module Resources
    # Automatically follow links to related resources
    module HasNestedResources
      extend HOALife::Concern

      class_methods do
        attr_reader :has_nested_resources

        def has_nested(key)
          @has_nested_resources ||= []

          @has_nested_resources.push(key)

          add_nested_resources_methods!(key)
        end

        private

        def add_nested_resources_methods!(key)
          define_method key do
            raw_value = @obj[key.to_s]
            if raw_value.is_a?(Array)
              raw_value.collect { |value| Resources::Collection.new(value['link']).all }.flatten
            else
              []
            end
          end
        end
      end
    end
  end
end
