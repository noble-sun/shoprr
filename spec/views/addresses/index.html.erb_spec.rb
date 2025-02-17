require 'rails_helper'

RSpec.describe "addresses/index", type: :view do
  before(:each) do
    assign(:addresses, [
      Address.create!(
        user: nil,
        street: "Street",
        number: 2,
        neighborhood: "Neighborhood",
        city: "City",
        state: "State",
        zipcode: "Zipcode",
        country: "Country",
        primary_address: false
      ),
      Address.create!(
        user: nil,
        street: "Street",
        number: 2,
        neighborhood: "Neighborhood",
        city: "City",
        state: "State",
        zipcode: "Zipcode",
        country: "Country",
        primary_address: false
      )
    ])
  end

  it "renders a list of addresses" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Street".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Neighborhood".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("City".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("State".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Zipcode".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Country".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(false.to_s), count: 2
  end
end
