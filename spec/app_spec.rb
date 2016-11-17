# frozen_string_literal: true
require File.expand_path '../spec_helper.rb', __FILE__

describe 'Alexa Charge Customer application' do
  let(:request_path) { File.expand_path('../fixtures/request.json', __FILE__) }
  let(:request_file) { File.read(request_path) }
  let(:request_data) { JSON.parse(request_file) }

  let(:post_service) { post '/service', request_data.to_json }

  # The application validates the Alexa application ID. Fill in the request fixture with
  # the one set in our environment variables so this will work whatever you have set.
  # We already use VCR's `filter_sensitive_data` to make requests non-environment variable
  # dependent, but we need to make the request work too.
  before do
    request_data['session']['application']['applicationId'] =
      Prius.get(:alexa_application_id)
  end

  context 'with a valid name' do
    it 'returns a success message with the name, amount and charge date' do
      VCR.use_cassette('gocardless/charge_customer_valid') do
        post_service

        expect(last_response.body).to include('Konnaire')
        expect(last_response.body).to include('5 pounds')
        expect(last_response.body).to include('2016-11-22')
      end
    end

    context 'with an OAuth access token in the session' do
      let(:request_path) do
        File.expand_path('../fixtures/request_with_access_token.json', __FILE__)
      end

      it 'returns a success message with the name, amount and charge date' do
        VCR.use_cassette('gocardless/charge_customer_valid') do
          post_service

          expect(last_response.body).to include('Konnaire')
          expect(last_response.body).to include('5 pounds')
          expect(last_response.body).to include('2016-11-22')
        end
      end

      it 'passes the access token to the services' do
        VCR.use_cassette('gocardless/charge_customer_valid') do
          expect(CustomerLookupService).to receive(:new).
            with(access_token: 'dummy_oauth_access_token').and_call_original
          expect(PaymentService).to receive(:new).
            with(access_token: 'dummy_oauth_access_token').and_call_original

          post_service
        end
      end
    end
  end

  context 'with a name with multiple matches' do
    before { request_data['request']['intent']['slots']['GivenName']['value'] = 'Emma' }

    it 'returns an error with the provided name' do
      VCR.use_cassette('gocardless/charge_customer_multiple_matches') do
        post_service

        expect(last_response.body).to include('Emma')
        expect(last_response.body).to include('more than one customer')
      end
    end
  end

  context "with a name that doesn't exist" do
    before { request_data['request']['intent']['slots']['GivenName']['value'] = 'Bob' }

    it 'returns a message saying the details are invalid' do
      VCR.use_cassette('gocardless/charge_customer_invalid') do
        post_service

        expect(last_response.body).to include("we couldn't find a customer called Bob")
      end
    end
  end

  context 'when there are too many customers, triggering a timeout' do
    before do
      allow_any_instance_of(CustomerLookupService).to receive(:find_by_given_name).
        with('Konnaire').and_raise(CustomerLookupService::TooManyCustomersError)
    end

    it 'returns a message saying there are too many customers' do
      VCR.use_cassette('gocardless/charge_customer_too_many_customers') do
        post_service

        expect(last_response.body).to include('too many Go Cardless customers')
      end
    end
  end
end
