# frozen_string_literal: true

require 'faraday'
class ActivityService
  attr_reader :url, :endpoint, :data

  def initialize(endpoint)
    # why are we passing an endpoint arg here? This class could be reused to hit multiple endpoints.
    @url = 'https://www.boredapi.com/api/'
    @endpoint = endpoint
  end

  def call
    get_data
    true
  rescue StandardError => e
    raise e.message
    false
  end

  def conn
    Faraday.new(
      url: url,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def get_data
    response = conn.get(endpoint.to_s)

    @data = JSON.parse(response.body)
  end
end
