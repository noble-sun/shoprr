FactoryBot.define do
  factory :identity_provider do
    association :user
    name { 'google' }
    account_identifier { 'google-sub-1234-aasdf' }
    access_token { 'google-access-token' }
    id_token { 'id-token-1234asddf'}
    expires_in { DateTime.now + 1.hour }
    refresh_token { 'google-refresh-token-123asdf'}
  end
end
