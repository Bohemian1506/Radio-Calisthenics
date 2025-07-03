require 'rails_helper'

RSpec.describe "Badges", type: :request do
  let(:badge) { create(:badge, :milestone_badge) }

  describe "GET /badges" do
    it "redirects to login when not authenticated" do
      get "/badges"
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /badges/:id" do
    it "redirects to login when not authenticated" do
      get "/badges/#{badge.id}"
      expect(response).to have_http_status(:redirect)
    end
  end
end
