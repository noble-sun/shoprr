require 'rails_helper'

RSpec.describe "addresses/show", type: :view do
  before(:each) do
    assign(:address, Address.create!(
      user: nil,
      street: "Street",
      number: 2,
      neighborhood: "Neighborhood",
      city: "City",
      state: "State",
      zipcode: "Zipcode",
      country: "Country",
      primary_address: false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Street/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Neighborhood/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/State/)
    expect(rendered).to match(/Zipcode/)
    expect(rendered).to match(/Country/)
    expect(rendered).to match(/false/)
  end
end
