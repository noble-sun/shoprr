FactoryBot.define do
  factory :cart_item do
    association :cart
    association :product
    quantity { 2 }
    price { "9.99" }
  end
end
