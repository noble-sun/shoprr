FactoryBot.define do
  factory :user do
    email_address { "email@email.com" }
    cpf { "79027123020" }
    password { 'Pass@123' }
  end
end
