FactoryBot.define do
  factory :identity_provider do
    association :user
    name { 'google' }
    account_identifier { 'google-sub-1234-aasdf' }
    access_token { 'google-access-token' }
    id_token { 'id-token-1234asddf'}
  end
end
