FactoryBot.define do
  factory :user do
    email_address { "email@email.com" }
    cpf { "12312312312" }
    password { 'pass@123' }
  end
end
