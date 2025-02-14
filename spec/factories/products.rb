FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:description) { |n| "Description of product #{n}" }
    quantity { 5 }
    price { 10.5 }
    active { true }

    after(:build) do |product|
      product.images.attach(
        io: File.open(Rails.root.join("spec/support/images/dog.jpg")),
        filename: "dog.jpg",
        content_type: "image/jpeg"
      )
    end

    trait :with_multiple_images do
      after(:build) do |product|
        product.images.attach(
          io: File.open(Rails.root.join("spec/support/images/cat.jpg")),
          filename: "cat.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end
