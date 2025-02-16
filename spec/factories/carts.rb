FactoryBot.define do
  factory :cart do
    status { 'active' }
    association :user
  end
end
