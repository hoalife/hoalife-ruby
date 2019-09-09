# frozen_string_literal: true

require 'bundler/setup'
require 'hoalife'

require 'securerandom'
require 'digest/md5'
require 'csv'

SEED = SecureRandom.hex

def hex_of(str)
  Digest::MD5.hexdigest(str)
end

def assert(bool)
  if bool
    print "\e[32m.\e[0m"
  else
    puts "\e[31m"
    puts "FAILED"
    puts caller
    print "\e[0m"
  end
end

def refute(bool)
  assert !bool
end

def assert_equal(exp, act)
  assert exp == act
end

def refute_equal(exp, act)
  assert exp != act
end

require_relative './account'
require_relative './property'
require_relative './ccr_article_and_violation_types'
