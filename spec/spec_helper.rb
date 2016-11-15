# frozen_string_literal: true
require 'rack/test'
require 'rspec'
require 'webmock/rspec'
require 'vcr'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.filter_sensitive_data('<access_token>') do |interaction|
    interaction.request.headers['Authorization'].first
  end

  c.filter_sensitive_data('<user agent>') do |interaction|
    interaction.request.headers['User-Agent'].first
  end

  c.filter_sensitive_data('<encoding>') do |interaction|
    interaction.request.headers['Accept-Encoding'].first
  end
end
