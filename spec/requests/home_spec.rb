require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    context "when user is not signed in" do
      it "redirects to login page" do
        get "/"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "returns http success and shows stamp cards page" do
        get "/"
        expect(response).to have_http_status(:success)
        expect(response.body).to include("📅 ラジオ体操カード")
      end
    end
  end
end
