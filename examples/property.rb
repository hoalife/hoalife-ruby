# frozen_string_literal: true

PROPERTY_ATTRS = %i[
  mailing_street_2 external_id mailing_street_1 mailing_city mailing_state mailing_postal_code
].freeze

original_size = HOALife::Property.count
csv = CSV.read(File.expand_path('properties.csv', __dir__), headers: true)

@parent = HOALife::Account.where(organizational: true).first
@associations = {}

def find_or_create_account(name)
  found = find_account(name)
  found || create_account(name)
end

def find_account(name)
  if @associations[name]
    @associations[name]
  else
    account = HOALife::Account.where(name: name).first
    @associations[name] = account if account
  end
end

def create_account(name)
  account = HOALife::Account.create(name: name, parent_id: @parent.id)

  @associations[name] = account

  account
end

csv.each do |row|
  association = find_or_create_account(row['association_name'])

  attrs = row.to_h.merge(
    account_id: association.id, phone_numbers: row['phone_numbers'].split('|'),
    emails: row['emails'].split('|')
  )

  property = HOALife::Property.create(attrs)
  assert(property.errors.nil?)
  refute(property.id.nil?)
end

refute_equal(original_size, HOALife::Property.reload.count)

csv.each do |row|
  find_by_external_id = HOALife::Property.where(external_id: row['external_id'])
  assert_equal 1, find_by_external_id.count

  found = find_by_external_id.first

  new_external_id = row['external_id'] + 'WithAChange'
  found.external_id = new_external_id
  assert(found.save)

  assert_equal 1, HOALife::Property.where(external_id: new_external_id).count
  assert found.destroy
end

@associations.each do |_, account|
  assert account.destroy
end

assert_equal(original_size, HOALife::Property.reload.count)
