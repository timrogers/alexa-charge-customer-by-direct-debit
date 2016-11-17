# frozen_string_literal: true
require 'alexa_skills_ruby'
require_relative 'customer_lookup_service'
require_relative 'payment_service'

class ChargeCustomerHandler < AlexaSkillsRuby::Handler
  on_intent('ChargeCustomer') { charge_customer }

  private

  def charge_customer
    customer = customers.find_by_given_name(given_name)
    return customer_not_found_message if customer.nil?

    payment = payments.charge(customer: customer, amount_in_pence: amount_in_pence)
    charged_successfully_message(payment.charge_date)
  rescue CustomerLookupService::TooManyCustomersError
    too_many_customers_message
  rescue CustomerLookupService::MoreThanOneMatchingCustomerError
    more_than_one_matching_customer_message
  rescue => exception
    generic_error(exception)
  end

  def given_name
    request.intent.slots['GivenName']
  end

  def amount
    request.intent.slots['Amount'].to_i
  end

  def amount_in_pence
    amount * 100
  end

  def customers
    CustomerLookupService.new(access_token: access_token)
  end

  def payments
    PaymentService.new(access_token: access_token)
  end

  def access_token
    session.user.access_token || Prius.get(:gocardless_access_token)
  end

  def charged_successfully_message(charge_date)
    response.set_output_speech_text("We've successfully charged #{given_name} #{amount}" \
                                    " pounds, and they'll be charged on #{charge_date}.")
  end

  def too_many_customers_message
    response.set_output_speech_text('Sorry - you have too many Go Cardless customers, ' \
                                    "so we couldn't look up #{given_name}.")
  end

  def more_than_one_matching_customer_message
    response.set_output_speech_text('Sorry - we found more than one customer called ' \
                                    "#{given_name}, so we couldn't tell who to charge.")
  end

  def customer_not_found_message
    response.set_output_speech_text("Sorry - we couldn't find a customer called " \
                                    "#{given_name} - check your Dashboard and try again.")
  end

  def generic_error(exception)
    logger.info "An unknown error occurred: #{exception}"
    response.set_output_speech_text('Sorry - something went wrong when we were charging' \
                                    " #{given_name}. Check your Dashboard to make sure " \
                                    "they weren't charged, then try again.")
  end
end
