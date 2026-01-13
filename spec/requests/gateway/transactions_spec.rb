# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Gateway::Transactions", type: :request do
  let(:provider_base_url) { "https://provider.example.com" }
  let(:valid_params) { { amount: 100, currency: "EUR", id: "txn_123" } }
  let(:headers) { { "Content-Type" => "application/json" } }

  describe "POST /gateway/transactions" do
    context "with valid request" do
      before do
        stub_request(:post, "#{provider_base_url}/transactions/init")
          .with(body: valid_params.to_json)
          .to_return(
            status: 200,
            body: { transaction_id: "provider_txn_456", status: "pending" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns 200 with redirect_url" do
        post "/gateway/transactions", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["redirect_url"]).to eq("https://our-app.test/transactions/auth/provider_txn_456")
      end
    end

    context "with missing required fields" do
      it "returns 422 when amount is missing" do
        post "/gateway/transactions",
             params: { currency: "EUR", id: "txn_123" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("validation_error")
        expect(json["message"]).to include("amount")
      end

      it "returns 422 when currency is missing" do
        post "/gateway/transactions",
             params: { amount: 100, id: "txn_123" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("validation_error")
        expect(json["message"]).to include("currency")
      end

      it "returns 422 when id is missing" do
        post "/gateway/transactions",
             params: { amount: 100, currency: "EUR" }.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("validation_error")
        expect(json["message"]).to include("id")
      end

      it "returns 422 with all missing fields listed" do
        post "/gateway/transactions",
             params: {}.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("validation_error")
        expect(json["message"]).to include("amount")
        expect(json["message"]).to include("currency")
        expect(json["message"]).to include("id")
      end
    end

    context "when Provider returns an error" do
      before do
        stub_request(:post, "#{provider_base_url}/transactions/init")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "returns 502 Bad Gateway" do
        post "/gateway/transactions", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:bad_gateway)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("provider_error")
        expect(json["message"]).to include("500")
      end
    end

    context "when Provider times out" do
      before do
        stub_request(:post, "#{provider_base_url}/transactions/init")
          .to_timeout
      end

      it "returns 504 Gateway Timeout" do
        post "/gateway/transactions", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:gateway_timeout)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("provider_error")
        expect(json["message"]).to include("timed out")
      end
    end

    context "with non-JSON Content-Type" do
      it "returns 415 Unsupported Media Type for form data" do
        post "/gateway/transactions",
             params: valid_params,
             headers: { "Content-Type" => "application/x-www-form-urlencoded" }

        expect(response).to have_http_status(:unsupported_media_type)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("unsupported_media_type")
        expect(json["message"]).to include("application/json")
      end

      it "returns 415 Unsupported Media Type when Content-Type is missing" do
        post "/gateway/transactions", params: valid_params.to_json

        expect(response).to have_http_status(:unsupported_media_type)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("unsupported_media_type")
      end
    end
  end
end
