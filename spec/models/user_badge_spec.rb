require 'rails_helper'

RSpec.describe UserBadge, type: :model do
  describe "associations" do
    it "belongs to user" do
      should belong_to(:user)
    end

    it "belongs to badge" do
      should belong_to(:badge)
    end
  end

  describe "validations" do
    subject { create(:user_badge) }

    it "validates uniqueness of user_id scoped to badge_id" do
      should validate_uniqueness_of(:user_id).scoped_to(:badge_id)
    end

    it "validates presence of earned_at" do
      should validate_presence_of(:earned_at)
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:badge1) { create(:badge, :milestone_badge) }
    let(:badge2) { create(:badge, :streak_badge) }

    describe ".recent" do
      it "orders by earned_at DESC" do
        user_badge1 = create(:user_badge, user: user, badge: badge1, earned_at: 2.days.ago)
        user_badge2 = create(:user_badge, user: user, badge: badge2, earned_at: 1.day.ago)

        recent_badges = UserBadge.recent
        expect(recent_badges.first).to eq(user_badge2)
        expect(recent_badges.second).to eq(user_badge1)
      end
    end

    describe ".by_badge_type" do
      it "filters by badge type" do
        milestone_user_badge = create(:user_badge, user: user, badge: badge1)
        streak_user_badge = create(:user_badge, user: user, badge: badge2)

        milestone_badges = UserBadge.by_badge_type('milestone')
        expect(milestone_badges).to include(milestone_user_badge)
        expect(milestone_badges).not_to include(streak_user_badge)
      end
    end
  end

  describe "callbacks" do
    describe "before_validation on create" do
      it "sets earned_at to current time if not provided" do
        user_badge = build(:user_badge, earned_at: nil)
        expect { user_badge.save! }.to change { user_badge.earned_at }.from(nil)
        expect(user_badge.earned_at).to be_within(1.second).of(Time.current)
      end

      it "does not overwrite earned_at if already set" do
        custom_time = 1.hour.ago
        user_badge = build(:user_badge, earned_at: custom_time)
        user_badge.save!
        expect(user_badge.earned_at.to_i).to eq(custom_time.to_i)
      end
    end
  end

  describe ".award_badge_to_user" do
    let(:user) { create(:user) }
    let(:badge) { create(:badge, :milestone_badge) }

    context "when user can earn the badge" do
      before do
        allow(user).to receive(:total_stamps).and_return(10)
        allow(badge).to receive(:can_be_earned_by?).with(user).and_return(true)
      end

      it "creates a user_badge record" do
        expect {
          UserBadge.award_badge_to_user(user, badge)
        }.to change(UserBadge, :count).by(1)
      end

      it "returns the created user_badge" do
        user_badge = UserBadge.award_badge_to_user(user, badge)
        expect(user_badge).to be_a(UserBadge)
        expect(user_badge.user).to eq(user)
        expect(user_badge.badge).to eq(badge)
      end
    end

    context "when user already has the badge" do
      before do
        create(:user_badge, user: user, badge: badge)
      end

      it "returns false" do
        result = UserBadge.award_badge_to_user(user, badge)
        expect(result).to be false
      end

      it "does not create a new user_badge" do
        expect {
          UserBadge.award_badge_to_user(user, badge)
        }.not_to change(UserBadge, :count)
      end
    end

    context "when user cannot earn the badge" do
      before do
        allow(badge).to receive(:can_be_earned_by?).with(user).and_return(false)
      end

      it "returns false" do
        result = UserBadge.award_badge_to_user(user, badge)
        expect(result).to be false
      end

      it "does not create a new user_badge" do
        expect {
          UserBadge.award_badge_to_user(user, badge)
        }.not_to change(UserBadge, :count)
      end
    end
  end
end
