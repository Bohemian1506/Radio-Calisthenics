FactoryBot.define do
  factory :badge do
    sequence(:name) { |n| "Test Badge #{n}" }
    description { "This is a test badge description" }
    icon { "🎯" }
    badge_type { "milestone" }
    conditions { { required_count: 10 } }
    active { true }
    sort_order { 1 }

    trait :streak_badge do
      badge_type { "streak" }
      conditions { { required_days: 7 } }
      icon { "🔥" }
    end

    trait :milestone_badge do
      badge_type { "milestone" }
      conditions { { required_count: 50 } }
      icon { "🏆" }
    end

    trait :early_bird_badge do
      badge_type { "early_bird" }
      conditions { { required_count: 10, cutoff_time: "07:00" } }
      icon { "🌅" }
    end

    trait :inactive do
      active { false }
    end
  end
end
