# frozen_string_literal: true
require 'sinatra'
require 'gocardless_pro'
require 'dotenv'
require 'alexa_skills_ruby'
require 'prius'
require_relative 'lib/charge_customer_handler'

Dotenv.load
Prius.load(:gocardless_access_token)
Prius.load(:alexa_application_id)

post '/service' do
  content_type :json

  handler = ChargeCustomerHandler.new(
    application_id: Prius.get(:alexa_application_id),
    logger: logger
  )

  begin
    handler.handle(request.body.read)
  rescue AlexaSkillsRuby::InvalidApplicationId => exception
    logger.error exception.to_s
    403
  end
end
