require 'rails_helper'

RSpec.describe User, type: :model do
  describe "basic functionality" do
    let(:user) { build(:user) }

    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "has an email" do
      expect(user.email).to be_present
    end
  end

  describe "admin functionality" do
    let(:user) { create(:user, admin: false) }
    let(:admin) { create(:user, admin: true) }

    it "returns false for regular user" do
      expect(user.admin?).to be false
    end

    it "returns true for admin user" do
      expect(admin.admin?).to be true
    end
  end

  describe "badge functionality" do
    let(:user) { create(:user) }
    let(:badge1) { create(:badge, :milestone_badge) }
    let(:badge2) { create(:badge, :streak_badge) }

    describe "#earned_badges" do
      before do
        create(:user_badge, user: user, badge: badge1, earned_at: 2.days.ago)
        create(:user_badge, user: user, badge: badge2, earned_at: 1.day.ago)
      end

      it "returns earned badges ordered by earned_at DESC" do
        earned_badges = user.earned_badges
        expect(earned_badges.first).to eq(badge2)
        expect(earned_badges.second).to eq(badge1)
      end
    end

    describe "#badge_count" do
      context "when user has no badges" do
        it "returns 0" do
          expect(user.badge_count).to eq(0)
        end
      end

      context "when user has badges" do
        before do
          create(:user_badge, user: user, badge: badge1)
          create(:user_badge, user: user, badge: badge2)
        end

        it "returns the correct count" do
          expect(user.badge_count).to eq(2)
        end
      end
    end

    describe "#has_badge?" do
      context "when user has the badge" do
        before { create(:user_badge, user: user, badge: badge1) }

        it "returns true" do
          expect(user.has_badge?(badge1)).to be true
        end
      end

      context "when user does not have the badge" do
        it "returns false" do
          expect(user.has_badge?(badge1)).to be false
        end
      end
    end

    describe "#latest_badge" do
      context "when user has no badges" do
        it "returns nil" do
          expect(user.latest_badge).to be_nil
        end
      end

      context "when user has badges" do
        before do
          create(:user_badge, user: user, badge: badge1, earned_at: 2.days.ago)
          create(:user_badge, user: user, badge: badge2, earned_at: 1.day.ago)
        end

        it "returns the most recently earned badge" do
          expect(user.latest_badge).to eq(badge2)
        end
      end
    end

    describe "#earned_badge_at" do
      let(:earned_time) { 1.day.ago.beginning_of_minute }

      context "when user has earned the badge" do
        before { create(:user_badge, user: user, badge: badge1, earned_at: earned_time) }

        it "returns the earned time" do
          expect(user.earned_badge_at(badge1).to_i).to eq(earned_time.to_i)
        end
      end

      context "when user has not earned the badge" do
        it "returns nil" do
          expect(user.earned_badge_at(badge1)).to be_nil
        end
      end
    end

    describe "#check_and_award_new_badges!" do
      let!(:active_badge) { create(:badge, badge_type: 'milestone', conditions: { required_count: 5 }) }
      let!(:inactive_badge) { create(:badge, :inactive, badge_type: 'milestone', conditions: { required_count: 1 }) }

      before do
        allow(user).to receive(:total_stamps).and_return(10)
      end

      context "when user can earn new badges" do
        it "awards the badge and returns it" do
          newly_earned = user.check_and_award_new_badges!
          expect(newly_earned).to include(active_badge)
          expect(user.has_badge?(active_badge)).to be true
        end

        it "does not award inactive badges" do
          newly_earned = user.check_and_award_new_badges!
          expect(newly_earned).not_to include(inactive_badge)
          expect(user.has_badge?(inactive_badge)).to be false
        end
      end

      context "when user already has the badge" do
        before { create(:user_badge, user: user, badge: active_badge) }

        it "does not award the badge again" do
          newly_earned = user.check_and_award_new_badges!
          expect(newly_earned).to be_empty
        end
      end
    end
  end
end
