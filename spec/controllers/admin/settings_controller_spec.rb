require "rails_helper"

RSpec.describe Admin::SettingsController, type: :controller do
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

      it "assigns participation times" do
        get :index
        expect(assigns(:participation_start_time)).to be_present
        expect(assigns(:participation_end_time)).to be_present
      end
    end

    context "when user is not admin" do
      before do
        sign_in regular_user
      end

      it "redirects to root path" do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("管理者権限が必要です。")
      end
    end
  end

  describe "PATCH #update" do
    context "when user is admin" do
      before do
        sign_in admin_user
      end

      context "with valid time format" do
        it "updates participation start time" do
          patch :update, params: {
            setting_name: "participation_start_time",
            setting_value: "07:00"
          }

          expect(response).to redirect_to(admin_settings_path)
          expect(flash[:notice]).to eq("設定を更新しました。")
        end

        it "updates participation end time" do
          patch :update, params: {
            setting_name: "participation_end_time",
            setting_value: "18:00"
          }

          expect(response).to redirect_to(admin_settings_path)
          expect(flash[:notice]).to eq("設定を更新しました。")
        end
      end

      context "with invalid time format" do
        it "redirects with error message" do
          patch :update, params: {
            setting_name: "participation_start_time",
            setting_value: "invalid_time"
          }

          expect(response).to redirect_to(admin_settings_path)
          expect(flash[:alert]).to eq("無効な設定値です。")
        end
      end

      context "with invalid setting name" do
        it "redirects with error message" do
          patch :update, params: {
            setting_name: "invalid_setting",
            setting_value: "07:00"
          }

          expect(response).to redirect_to(admin_settings_path)
          expect(flash[:alert]).to eq("無効な設定値です。")
        end
      end
    end

    context "when user is not admin" do
      before do
        sign_in regular_user
      end

      it "redirects to root path" do
        patch :update, params: {
          setting_name: "participation_start_time",
          setting_value: "07:00"
        }

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("管理者権限が必要です。")
      end
    end
  end
end
