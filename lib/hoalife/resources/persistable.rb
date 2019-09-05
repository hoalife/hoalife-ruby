# frozen_string_literal: true

module HOALife
  module Resources
    # Persist an object
    module Persistable
      include Requestable

      def save
        self.errors = nil

        if id.nil?
          create!
        else
          update!
        end

        self.errors.nil?
      end

      def destroy
        response = Client::Delete.new(update_url)

        response.status == 202
      end

      private

      def create_url
        HOALife.api_base + self.class.base_path
      end

      def update_url
        HOALife.api_base + self.class.base_path + "/#{id}"
      end

      def create!
        make_request! do
          response = Client::Post.new(create_url, to_json)

          assign_updated_data!(response.json)
        end
      rescue HOALife::BadRequestError => e
        assign_errors!(e)
      end

      def update!
        make_request! do
          response = Client::Put.new(update_url, to_json)

          assign_updated_data!(response.json)
        end
      rescue HOALife::BadRequestError => e
        assign_errors!(e)
      end

      def destroy!
        make_request! do
          response = Client::Delete.new(update_url)

          assign_updated_data!(response.json)
        end
      rescue HOALife::BadRequestError => e
        assign_errors!(e)
      end

      def assign_updated_data!(data)
        @obj = cast_attrs(data.dig('data', 'attributes'))

        data.dig('data', 'attributes').each { |k, v| self.send("#{k}=", v) }
      end

      def assign_errors!(e)
        self.errors = OpenStruct.new(e.details.dig('data', 'attributes'))
      end
    end
  end
end
