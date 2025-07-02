require "rails_helper"

RSpec.describe StampCardsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns stamp cards for current user" do
      stamp_card = create(:stamp_card, user: user)
      get :index
      expect(assigns(:stamp_cards)).to include(stamp_card)
    end

    it "generates calendar days" do
      get :index
      expect(assigns(:calendar_days)).to be_present
      expect(assigns(:calendar_days).length).to eq(6) # 6 weeks
    end
  end

  describe "POST #create" do
    context "when user has not stamped today" do
      before do
        allow(AdminSetting).to receive(:participation_start_time).and_return("06:00")
        allow(AdminSetting).to receive(:participation_end_time).and_return("23:59")
        allow(Time).to receive(:current).and_return(Time.parse("2025-01-01 12:00:00"))
      end

      it "creates a new stamp card" do
        expect {
          post :create
        }.to change(StampCard, :count).by(1)
      end

      it "redirects to index with success message" do
        post :create
        expect(response).to redirect_to(stamp_cards_path)
        expect(flash[:notice]).to eq("スタンプを押しました！")
      end
    end

    context "when user has already stamped today" do
      before do
        create(:stamp_card, user: user, date: Date.current)
      end

      it "does not create a new stamp card" do
        expect {
          post :create
        }.not_to change(StampCard, :count)
      end

      it "redirects with alert message" do
        post :create
        expect(response).to redirect_to(stamp_cards_path)
        expect(flash[:alert]).to eq("今日はすでにスタンプを押しています。")
      end
    end

    context "when outside participation time" do
      before do
        allow(AdminSetting).to receive(:participation_start_time).and_return("06:00")
        allow(AdminSetting).to receive(:participation_end_time).and_return("07:00")
        allow(Time).to receive(:current).and_return(Time.parse("2025-01-01 12:00:00"))
      end

      it "does not create a stamp card" do
        expect {
          post :create
        }.not_to change(StampCard, :count)
      end

      it "redirects with time restriction message" do
        post :create
        expect(response).to redirect_to(stamp_cards_path)
        expect(flash[:alert]).to include("スタンプは06:00〜07:00の間のみ押すことができます。")
      end
    end
  end

  describe "authentication" do
    context "when user is not logged in" do
      before do
        sign_out user
      end

      it "redirects to login page for index" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "redirects to login page for create" do
        post :create
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
