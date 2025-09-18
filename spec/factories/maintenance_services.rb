FactoryBot.define do
  factory :maintenance_service do
    vehicle { nil }
    description { "MyString" }
    status { "MyString" }
    date { "2025-09-16" }
    cost_cents { 1 }
    priority { "MyString" }
    completed_at { "2025-09-16 15:17:47" }
  end
end
