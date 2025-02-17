FactoryBot.define do
  factory :order do
    user { nil }
    address { nil }
    status { "MyString" }
    cart { nil }
  end
end
