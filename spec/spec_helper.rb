ENV['RUBY_ENV'] ||= 'test'
require 'byebug'
require 'rdmapper'

RSpec.configure do |config|
  config.color = true
end
