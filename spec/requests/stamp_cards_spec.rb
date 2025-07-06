require 'rails_helper'

RSpec.describe "StampCards", type: :request do
  include Devise::Test::IntegrationHelpers
  let(:user) { create(:user) }
  let(:current_month) { Date.current.beginning_of_month }

  def authenticate_user
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  describe "GET /stamp_cards" do
    context "when user is authenticated" do
      before { authenticate_user }

      it "returns http success" do
        get stamp_cards_path
        expect(response).to have_http_status(:success)
      end

      it "displays monthly calendar" do
        get stamp_cards_path
        expect(response.body).to include("スタンプカード")
        expect(response.body).to include(current_month.strftime("%Y年%m月"))
      end
    end

    context "when user is not authenticated" do
      it "redirects to login" do
        get stamp_cards_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /stamp_cards" do
    context "when user is authenticated" do
      before { authenticate_user }

      let(:valid_attributes) do
        {
          stamp_card: {
            date: Date.current,
            stamped_at: Time.current
          }
        }
      end

      it "creates a new stamp card" do
        expect {
          post stamp_cards_path, params: valid_attributes
        }.to change(StampCard, :count).by(1)
      end

      it "redirects to stamp cards index" do
        post stamp_cards_path, params: valid_attributes
        expect(response).to redirect_to(stamp_cards_path)
      end
    end
  end

  describe "DELETE /stamp_cards/:id" do
    context "when user is authenticated" do
      before { authenticate_user }

      let!(:stamp_card) { create(:stamp_card, user: user) }

      it "destroys the stamp card" do
        expect {
          delete stamp_card_path(stamp_card)
        }.to change(StampCard, :count).by(-1)
      end

      it "redirects to stamp cards index" do
        delete stamp_card_path(stamp_card)
        expect(response).to redirect_to(stamp_cards_path)
      end
    end
  end

  describe "private methods" do
    context "when user is authenticated" do
      before { authenticate_user }

      describe "parse_month_params" do
        it "parses valid year and month" do
          get stamp_cards_path, params: { year: 2024, month: 6 }
          expect(response).to have_http_status(:success)
        end

        it "handles invalid year and month" do
          get stamp_cards_path, params: { year: "invalid", month: "invalid" }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
