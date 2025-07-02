class AdminSetting < ApplicationRecord
  validates :setting_name, presence: true, uniqueness: true
  validates :setting_value, presence: true

  def self.get_value(name)
    find_by(setting_name: name)&.setting_value
  end

  def self.set_value(name, value)
    setting = find_or_initialize_by(setting_name: name)
    setting.setting_value = value
    setting.save!
    setting
  end

  def self.participation_start_time
    get_value("participation_start_time") || "06:00"
  end

  def self.participation_end_time
    get_value("participation_end_time") || "06:30"
  end
end
