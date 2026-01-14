# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransactionsAuth", type: :request do
  let(:provider_base_url) { "https://provider.example.com" }
  let(:transaction_id) { "txn_abc123" }

  describe "GET /transactions/auth/:id" do
    context "when Provider returns success" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(
            status: 200,
            body: { status: "success" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "renders 'success'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("success")
      end
    end

    context "when Provider returns status 'failed'" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(
            status: 200,
            body: { status: "failed" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end

    context "when Provider returns status 'pending'" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(
            status: 200,
            body: { status: "pending" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end

    context "when Provider returns 500 error" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end

    context "when Provider times out" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_timeout
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end

    context "when Provider returns invalid JSON" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(
            status: 200,
            body: "not valid json",
            headers: { "Content-Type" => "text/plain" }
          )
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end

    context "when Provider returns 404" do
      before do
        stub_request(:put, "#{provider_base_url}/transactions/auth/#{transaction_id}")
          .to_return(status: 404, body: "Not Found")
      end

      it "renders 'failed'" do
        get "/transactions/auth/#{transaction_id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq("failed")
      end
    end
  end
end
