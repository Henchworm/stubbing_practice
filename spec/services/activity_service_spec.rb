# frozen_string_literal: true

require './lib/services/activity_service'
require 'spec_helper'
require 'webmock'
require 'vcr'
RSpec.describe ActivityService do
  let!(:endpoint) { 'activity/' }
  let!(:activity_service) { ActivityService.new(endpoint) }
  let!(:response_hash) do
    # this is the actual JSON response from hitting the API -- for testing,
    # mock responses should consist of only relevant information.
    { 'activity' => 'Take your dog on a walk',
      'type' => 'relaxation',
      'participants' => 1,
      'price' => 0,
      'link' => '',
      'key' => '9318514',
      'accessibility' => 0.2 }
  end

  context 'success' do
    # not stubbed - actual API response
    it 'returns parsed JSON data' do
      WebMock.enable_net_connect!
      VCR.turn_off!

      expect(activity_service.call).to eq(true)
      # while this test passes -- it's not very reliable. It's making an external call to the api,
      # wasting resources and possibly maxing out API credits. With a random API like this,
      # we're never able to truly test the content of the data returned.

      WebMock.disable_net_connect!
      VCR.turn_on!
    end

    # VCR
    it 'returns parsed JSON data' do
      # VCR takes a 'screenshot' of the data from the API, saves it to spec/cassettes, and then references it
      # every time the test is run.
      VCR.use_cassette 'activity_service' do
        expect(activity_service.call).to eq(true)
        # expect(activity_service.data).to eq(response_hash)
        # Notice how the above expect is commented out -- since VCR snapshots can
        # change, it becomes harder to test against it. We prefer using test stubs BASED
        #on actual data.
      end
    end

    # WebMock
    it 'returns parsed JSON data' do
      # stub_request is built into the Webmock library -- very handy, it'll auto-generate the stubs for
      # you if you attempt to make a real API call.
      stub_request(:get, 'https://www.boredapi.com/api/activity/')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v2.2.0'
          }
        )
        .to_return(status: 200, body: response_hash.to_json, headers: {})

      expect(activity_service.call).to eq(true)
      expect(activity_service.data).to eq(response_hash)
    end

    # traditional
    it 'returns parsed JSON data' do
      # for this test, we use the standard RSpec library and use a test double for the
      # Faraday::Connection response object.
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
        double('response', status: 200, body: response_hash.to_json)
      )

      expect(activity_service.call).to eq(true)
      expect(activity_service.data).to eq(response_hash)
    end
  end

  context 'failure' do
    # vcr
    xit 'returns 400 status and JSON data' do
    end

    # WebMock
    xit 'returns 400 status and JSON data' do
    end

    # traditional
    xit 'returns 400 status and JSON data' do
    end
  end
end
