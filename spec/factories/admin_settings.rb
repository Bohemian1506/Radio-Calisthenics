FactoryBot.define do
  factory :admin_setting do
    setting_name { "test_setting" }
    setting_value { "test_value" }

    trait :participation_start_time do
      setting_name { "participation_start_time" }
      setting_value { "06:00" }
    end

    trait :participation_end_time do
      setting_name { "participation_end_time" }
      setting_value { "06:30" }
    end
  end
end
