# frozen_string_literal: true

module Gateway
  class TransactionsController < ApplicationController
    skip_forgery_protection

    APP_HOST = ENV.fetch("APP_HOST", "https://our-app.test")

    before_action :verify_json_content_type
    before_action :validate_params

    def create
      result = provider_client.init_transaction(transaction_params)
      redirect_url = build_redirect_url(result[:transaction_id])

      render json: { redirect_url: redirect_url }, status: :ok
    rescue ProviderClient::TimeoutError => e
      render json: { error: "provider_error", message: e.message }, status: :gateway_timeout
    rescue ProviderClient::ApiError => e
      render json: { error: "provider_error", message: e.message }, status: :bad_gateway
    end

    private

    def verify_json_content_type
      return if request.content_type&.include?("application/json")

      render json: {
        error: "unsupported_media_type",
        message: "Content-Type must be application/json"
      }, status: :unsupported_media_type
    end

    def validate_params
      missing = %w[amount currency id].select { |key| params[key].blank? }
      return if missing.empty?

      render json: {
        error: "validation_error",
        message: "Missing required fields: #{missing.join(', ')}"
      }, status: :unprocessable_entity
    end

    def transaction_params
      params.permit(:amount, :currency, :id).to_h
    end

    def build_redirect_url(transaction_id)
      "#{APP_HOST}/transactions/auth/#{transaction_id}"
    end

    def provider_client
      @provider_client ||= ProviderClient.new
    end
  end
end
