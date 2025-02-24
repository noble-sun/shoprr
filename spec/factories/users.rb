FactoryBot.define do
  factory :user do
    name { 'Muhammad' }
    surname { 'Wang' }
    email_address { "email@email.com" }
    cpf { "79027123020" }
    password { 'Pass@123' }
    phone { '11987654321' }
    date_of_birth { '31/12/2000' }
    active { true }
    admin { false }
  end
end
