FactoryBot.define do
  factory :address do
    user { nil }
    street { "Rua dos Bobos" }
    number { 0 }
    neighborhood { "Vila dos Ingênuos" }
    city { "Paraíso" }
    state { "SP" }
    zipcode { "1000010" }
    country { "Brasil" }
    primary_address { true }
  end
end
