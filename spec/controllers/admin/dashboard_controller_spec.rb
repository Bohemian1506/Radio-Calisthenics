require "rails_helper"

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin_user) { create(:user, admin: true) }
  let(:regular_user) { create(:user, admin: false) }

  describe "GET #index" do
    context "when user is admin" do
      before do
        sign_in admin_user
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns dashboard statistics" do
        create_list(:user, 3)
        create_list(:stamp_card, 5)

        get :index

        expect(assigns(:total_users)).to be >= 1
        expect(assigns(:total_stamps)).to be >= 0
        expect(assigns(:today_stamps)).to be >= 0
        expect(assigns(:active_users)).to be >= 0
        expect(assigns(:recent_stamps)).to be_present
        expect(assigns(:daily_stats)).to be_present
      end
    end

    context "when user is not admin" do
      before do
        sign_in regular_user
      end

      it "redirects to root path with alert" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("管理者権限が必要です。")
      end
    end

    context "when user is not logged in" do
      it "redirects to login page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
