# frozen_string_literal: true

class ProviderClient
  class Error < StandardError; end
  class TimeoutError < Error; end
  class ApiError < Error; end

  BASE_URL = ENV.fetch("PROVIDER_BASE_URL", "https://provider.example.com")
  TIMEOUT = 10
  OPEN_TIMEOUT = 5

  def initialize
    @connection = Faraday.new(url: BASE_URL) do |conn|
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.options.timeout = TIMEOUT
      conn.options.open_timeout = OPEN_TIMEOUT
    end
  end

  # Initializes a transaction with the Provider
  # @param payload [Hash] { amount:, currency:, id: }
  # @return [Hash] { transaction_id:, status: }
  # @raise [TimeoutError] on connection timeout
  # @raise [ApiError] on non-2xx response
  def init_transaction(payload)
    response = @connection.post("/transactions/init", payload)

    unless response.success?
      raise ApiError, "Provider returned #{response.status}: #{response.body}"
    end

    response.body.slice("transaction_id", "status").symbolize_keys
  rescue Faraday::TimeoutError, Faraday::ConnectionFailed => e
    raise TimeoutError, "Provider request timed out: #{e.message}"
  rescue Faraday::Error => e
    raise ApiError, "Provider request failed: #{e.message}"
  end

  # Authenticates a transaction with the Provider
  # @param id [String] transaction ID
  # @return [Boolean] true only if Provider returns 200 + status "success"
  def auth_transaction(id)
    response = @connection.put("/transactions/auth/#{id}")

    return false unless response.success?
    return false unless response.body.is_a?(Hash)

    response.body["status"] == "success"
  rescue Faraday::Error
    false
  end
end
