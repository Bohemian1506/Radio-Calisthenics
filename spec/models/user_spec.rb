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
end
