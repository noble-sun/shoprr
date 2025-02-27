FactoryBot.define do
  factory :identity_provider do
    association :user
    name { 'google' }
    account_identifier { 'google-sub-1234-aasdf' }
  end
end
