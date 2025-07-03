FactoryBot.define do
  factory :badge do
    name { "MyString" }
    description { "MyText" }
    icon { "MyString" }
    badge_type { "MyString" }
    conditions { "" }
    active { false }
  end
end
