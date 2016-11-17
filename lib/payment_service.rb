# frozen_string_literal: true
require 'gocardless_pro'

class PaymentService
  ELIGIBLE_MANDATE_STATUSES = %w(active submitted pending_submission).freeze

  def initialize(access_token:)
    @access_token = access_token
  end

  def charge(customer:, amount_in_pence:)
    mandate = mandate_for_customer(customer)

    raise "Couldn't find the customer's mandate" if mandate.nil?

    client.payments.create(params: {
                             amount: amount_in_pence,
                             currency: 'GBP',
                             links: {
                               mandate: mandate.id
                             }
                           })
  end

  private

  attr_reader :access_token

  def mandate_for_customer(customer)
    client.mandates.
      list(params: { customer: customer.id, status: ELIGIBLE_MANDATE_STATUSES }).
      records.first
  end

  def client
    @client ||= GoCardlessPro::Client.new(access_token: access_token)
  end
end
