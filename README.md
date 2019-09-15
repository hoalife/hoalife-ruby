# HOALife - Ruby API Client

Pragmatic access to the HOALife REST API. [https://docs.hoalife.com](https://docs.hoalife.com).

[![Gem Version](https://badge.fury.io/rb/hoalife.svg)](https://badge.fury.io/rb/hoalife) [![Build Status](https://travis-ci.com/hoalife/hoalife-ruby.svg?branch=master)](https://travis-ci.com/hoalife/hoalife-ruby)

This library seamlessly handles pagination, CRUD actions, Rate Limiting, and Error handling for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hoalife'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hoalife

## Usage

### Configuration

Configure the client with your credentials in your code.

```ruby
HOALife.config do |config|
  config.api_key                 = 'sk_YOURSUPERSECRETKEY'
  config.signing_secret          = 'ss_YOURSIGNINGSECRET'
  config.sleep_when_rate_limited = 10.0 # Optional
end

# or

HOALife.api_key                 = 'sk_YOURSUPERSECRETKEY'
HOALife.signing_secret          = 'ss_YOURSIGNINGSECRET'
HOALife.sleep_when_rate_limited = 10.0 # Optional
```

Alternatively, you can specify the `api_key`, and `signing_secret` with environmental variables.

```sh
HOALIFE_API_KEY=sk_YOURSUPERSECRETKEY
HOALIFE_SIGNING_SECRET=ss_YOURSIGNINGSECRET

echo $HOALIFE_API_KEY # => sk_YOURSUPERSECRETKEY
echo $HOALIFE_SIGNING_SECRET # => ss_YOURSIGNINGSECRET
```

### Rate Limits

The HOALife API implements per-API Key rate limiting to prevent API abuse from impacting other customers. See the Rate Limiting section of [https://docs.hoalife.com](https://docs.hoalife.com) for details. This library can handle the rate limit in two different ways.

#### Sleep When Rate Limited (Default)

This method seamlessly handles hitting the rate limit for you by sleeping for a given period then trying the HTTP call when a `429 Rate Limit Exceeded` response is returned by the API. This will make the rate limit transparent to your script, and works best when using the API client in a single threaded, synchronous, fashion.

Set `HOALife#sleep_when_rate_limited` to a `Float` to configure the period that the client will sleep for before retrying the HTTP call.

#### Raise an Error When Rate Limited

If you're accessing the API from multiple machines/threads/processes, you may not want to sleep when the limit is hit, but instead handle the retry logic on your own. In this scenario, a `HOALife::RateLimitError` will be raised.

Set `HOALife#sleep_when_rate_limited` to `nil` to configure the client to raise an error instead of sleeping and retrying the HTTP call.

### Error Handling

This library tries to handle errors for you in a transparent and intuitive way so that you can resolve them and move forward. See `lib/hoalife/errors.rb` for a full list of the possible errors.

#### HTTP Based Errors

Errors caused by bad HTTP calls will provide additional information via the `HTTPError#status`, `HTTPError#headers` and `HTTPError#details` methods.

```ruby
# An invalid API Key
begin
  HOALife.api_key = 'foo'
  HOALife::Account.create(name: 'foobar')
rescue HOALife::HTTPError => e
  puts e.status # => 401
  puts e.headers # => {"content-type"=>"application/json; charset=utf-8", ... }
  puts e.details # => {"data"=>{"id"=>"7b06f5e7-a572-4639-bae6-02e41aa367dd", "type"=>"error", "attributes"=>{"id"=>"7b06f5e7-a572-4639-bae6-02e41aa367dd", "title"=>"Invalid API Key", "status"=>401, "detail"=>"Provided API key foo was not valid"}}}
end
```

```ruby
# API key does not have permission for the given action
begin
  HOALife::Account.create(name: 'foobar')
rescue HOALife::HTTPError => e
  puts e.status # => 403
  puts e.headers # => {"x-ratelimit-limit"=>"10", ... }
  puts e.details # => {"data"=>{"id"=>"80143c2b-1b1b-4b33-b31e-751e31da8e5a", "type"=>"error", "attributes"=>{"id"=>"80143c2b-1b1b-4b33-b31e-751e31da8e5a", "title"=>"Permission denied", "status"=>403, "detail"=>"This API key sk_YOURSUPERSECRETKEY does not have access to the requested resource"}}}
end
```

## Implemented Resources

Resource | READ | CREATE | UPDATE | DESTROY |
-------- | ----- |------- | ------ | ------- |
`HOALife::Account` | true | true | true | true |
`HOALife::Property` | true | true | true | true |
`HOALife::CCRArticle` | true | true | true | true |
`HOALife::CCRViolationType` | true | true | true | true |
`HOALife::Violation` | true | true | true | true |
`HOALife::Inspection` | true | false | false | false |
`HOALife::Escalation` | true | false | false | false |

## Reading Resources

Resources respond to many `ActiveRecord`-like methods like `all`, `count`, `first`, `last`, `total_pages`, `reload`, `where`, and `order`. All Resources respond to the Read methods.

### Examples

```ruby
# Get all accounts
accounts = HOALife::Account.all

# Get the first account
account = HOALife::Account.first

# Total count of the available resources
count = HOALife::Account.count

# Get the most recently created account
count = HOALife::Account.order(:created_at, :desc).first

# Get all accounts that match a condition
HOALife::Account.where(parent_id: 1).all

# Get the first account which matches a condition
HOALife::Account.where(external_id: 'myInternalId1').first

# Get all properties under a given account, ordered by external ID
HOALife::Property.where(account_id: 3).order(:external_id, :asc).all
```

## Creating Resources

Resources supporting creation respond to the `HOALife::Resource.create` class method, and the `HOALife::Resource#save` instance method.

### Examples

```ruby
# Create an account
account = HOALife::Account.create(parent_id: 1, name: "foo")
account.id # => 33
account.errors # => nil
account.persisted? # => true

# or

account = HOALife::Account.new(parent_id: 1, name: "foo")
account.save # => true
account.errors # => nil
account.persisted? # => true

# Account which doesn't meet data validation requirements
account = HOALife::Account.create()
account.id # => nil
account.persisted? # => false
account.errors.detail # => {"parent_id"=>"is invalid"}

# Property which doesn't meet data validation requirements
property = HOALife::Property.create(account_id: 2)
property.errors.detail # => {"street_1"=>"can't be blank", "city"=>"can't be blank", "state"=>"can't be blank", "postal_code"=>"can't be blank"}
```

## Updating Resources

Resources supporting updating respond to the `HOALife::Resource#save` instance method.

### Examples

```ruby
# Create an account
account = HOALife::Account.first
account.update(name: 'bar') # => true

# or

account.name = 'bar'
account.save # => true
account.name # => 'bar'

account.name = ''
account.save # => false
account.name # => ''
account.errors.detail # => {"name"=>"can't be blank"}
```

## Destroying Resources

Resources supporting deletion respond to the `HOALife::Resource#destroy` instance method.

### Examples

```ruby
# Create an account
account = HOALife::Account.first

account.destroy # => true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hoalife/hoalife-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
