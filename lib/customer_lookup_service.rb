# frozen_string_literal: true
require 'gocardless_pro'
require 'timeout'

class CustomerLookupService
  class TooManyCustomersError < StandardError; end
  class MoreThanOneMatchingCustomerError < StandardError; end

  TIMEOUT = 5

  def initialize(access_token:)
    @access_token = access_token
  end

  def find_by_given_name(given_name)
    Timeout.timeout(TIMEOUT) do
      matching_customers = customers.find_all do |customer|
        customer.given_name.casecmp(given_name)
      end

      return if matching_customers.count.zero?
      raise TooManyCustomersError if matching_customers.count > 1

      matching_customers.first
    end
  rescue Timeout::Error
    raise TooManyCustomersError
  end

  private

  attr_reader :access_token

  def customers
    client.customers.all(params: { active_mandates: true })
  end

  def client
    @client ||= GoCardlessPro::Client.new(access_token: access_token)
  end
end
