# frozen_string_literal: true

# Persist an object
module HOALife::Resources::Persistable
  include HOALife::Resources::Requestable
  extend HOALife::Concern

  class_methods do
    def create(attrs = {})
      new(attrs).save
    end
  end

  def save
    self.errors = nil

    if id.nil?
      create!
    else
      update!
    end

    errors.nil?
  end

  def destroy
    response = HOALife::Client::Delete.new(update_url)

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
      response = HOALife::Client::Post.new(create_url, to_json)

      assign_updated_data!(response.json)
    end
  rescue HOALife::BadRequestError => e
    assign_errors!(e)
  end

  def update!
    make_request! do
      response = HOALife::Client::Put.new(update_url, to_json)

      assign_updated_data!(response.json)
    end
  rescue HOALife::BadRequestError => e
    assign_errors!(e)
  end

  def destroy!
    make_request! do
      response = HOALife::Client::Delete.new(update_url)

      assign_updated_data!(response.json)
    end
  rescue HOALife::BadRequestError => e
    assign_errors!(e)
  end

  def assign_updated_data!(data)
    @obj = cast_attrs(data.dig('data', 'attributes'))

    data.dig('data', 'attributes').each { |k, v| send("#{k}=", v) }
  end

  def assign_errors!(err)
    self.errors = OpenStruct.new(err.details.dig('data', 'attributes'))
  end
end
