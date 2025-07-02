require 'rails_helper'

RSpec.describe AdminSetting, type: :model do
  describe "validations" do
    let(:admin_setting) { build(:admin_setting) }

    it "is valid with valid attributes" do
      expect(admin_setting).to be_valid
    end

    it "requires a setting_name" do
      admin_setting.setting_name = nil
      expect(admin_setting).not_to be_valid
    end

    it "requires a setting_value" do
      admin_setting.setting_value = nil
      expect(admin_setting).not_to be_valid
    end
  end

  describe "class methods" do
    describe ".set_value and .get_value" do
      it "stores and retrieves values" do
        AdminSetting.set_value("test_setting", "test_value")
        expect(AdminSetting.get_value("test_setting")).to eq("test_value")
      end
    end

    describe ".participation_start_time" do
      it "returns default time when not set" do
        expect(AdminSetting.participation_start_time).to eq("06:00")
      end

      it "returns set time when configured" do
        AdminSetting.set_value("participation_start_time", "07:00")
        expect(AdminSetting.participation_start_time).to eq("07:00")
      end
    end

    describe ".participation_end_time" do
      it "returns default time when not set" do
        expect(AdminSetting.participation_end_time).to eq("06:30")
      end

      it "returns set time when configured" do
        AdminSetting.set_value("participation_end_time", "08:00")
        expect(AdminSetting.participation_end_time).to eq("08:00")
      end
    end
  end
end
