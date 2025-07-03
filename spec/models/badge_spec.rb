require 'rails_helper'

RSpec.describe Badge, type: :model do
  describe 'associations' do
    it 'has many user_badges' do
      badge = Badge.new
      expect(badge).to respond_to(:user_badges)
    end

    it 'has many users through user_badges' do
      badge = Badge.new
      expect(badge).to respond_to(:users)
    end
  end

  describe 'validations' do
    it 'validates presence of name' do
      badge = Badge.new
      badge.valid?
      expect(badge.errors[:name]).to include("can't be blank")
    end

    it 'validates presence of description' do
      badge = Badge.new
      badge.valid?
      expect(badge.errors[:description]).to include("can't be blank")
    end

    it 'validates presence of icon' do
      badge = Badge.new
      badge.valid?
      expect(badge.errors[:icon]).to include("can't be blank")
    end

    it 'validates presence of badge_type' do
      badge = Badge.new
      badge.valid?
      expect(badge.errors[:badge_type]).to include("can't be blank")
    end

    it 'validates presence of conditions' do
      badge = Badge.new
      badge.valid?
      expect(badge.errors[:conditions]).to include("can't be blank")
    end
  end

  describe '#earned_by?' do
    let(:user) { create(:user) }
    let(:badge) { create(:badge) }

    context 'when user has earned the badge' do
      before { create(:user_badge, user: user, badge: badge) }

      it 'returns true' do
        expect(badge.earned_by?(user)).to be true
      end
    end

    context 'when user has not earned the badge' do
      it 'returns false' do
        expect(badge.earned_by?(user)).to be false
      end
    end
  end

  describe '#can_be_earned_by?' do
    let(:user) { create(:user) }
    let(:badge) { create(:badge, badge_type: 'milestone', conditions: { required_count: 10 }) }

    context 'when badge is inactive' do
      before { badge.update(active: false) }

      it 'returns false' do
        expect(badge.can_be_earned_by?(user)).to be false
      end
    end

    context 'when user already earned the badge' do
      before { create(:user_badge, user: user, badge: badge) }

      it 'returns false' do
        expect(badge.can_be_earned_by?(user)).to be false
      end
    end
  end

  describe 'class methods' do
    describe '.badge_types' do
      it 'returns the badge types hash' do
        expect(Badge.badge_types).to eq(Badge::BADGE_TYPES)
      end
    end

    describe '.active scope' do
      let!(:active_badge) { create(:badge, active: true) }
      let!(:inactive_badge) { create(:badge, active: false) }

      it 'returns only active badges' do
        active_badges = Badge.active
        expect(active_badges).to include(active_badge)
        expect(active_badges).not_to include(inactive_badge)
      end
    end
  end
end
