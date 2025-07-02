require 'rails_helper'

RSpec.describe StampCard, type: :model do
  describe "validations" do
    let(:stamp_card) { build(:stamp_card) }

    it "is valid with valid attributes" do
      expect(stamp_card).to be_valid
    end

    it "requires a user" do
      stamp_card.user = nil
      expect(stamp_card).not_to be_valid
    end

    it "requires a date" do
      stamp_card.date = nil
      expect(stamp_card).not_to be_valid
    end

    it "requires a stamped_at time" do
      stamp_card.stamped_at = nil
      expect(stamp_card).not_to be_valid
    end
  end

  describe "class methods" do
    let(:user) { create(:user) }

    describe ".stamped_today?" do
      context "when user has stamped today" do
        before do
          create(:stamp_card, user: user, date: Date.current)
        end

        it "returns true" do
          expect(StampCard.stamped_today?(user)).to be true
        end
      end

      context "when user has not stamped today" do
        it "returns false" do
          expect(StampCard.stamped_today?(user)).to be false
        end
      end
    end
  end
end
