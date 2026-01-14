# frozen_string_literal: true

class TransactionsAuthController < ApplicationController
  def show
    id = params[:id]

    if id.blank?
      render plain: "failed", status: :ok
      return
    end

    result = provider_client.auth_transaction(id)
    render plain: (result ? "success" : "failed"), status: :ok
  end

  private

  def provider_client
    @provider_client ||= ProviderClient.new
  end
end
