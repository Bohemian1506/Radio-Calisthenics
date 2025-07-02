FactoryBot.define do
  factory :stamp_card do
    association :user
    date { Date.current }
    stamped_at { Time.current }
  end
end
