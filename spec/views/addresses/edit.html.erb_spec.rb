require 'rails_helper'

RSpec.describe "addresses/edit", type: :view do
  let(:address) {
    Address.create!(
      user: nil,
      street: "MyString",
      number: 1,
      neighborhood: "MyString",
      city: "MyString",
      state: "MyString",
      zipcode: "MyString",
      country: "MyString",
      primary_address: false
    )
  }

  before(:each) do
    assign(:address, address)
  end

  it "renders the edit address form" do
    render

    assert_select "form[action=?][method=?]", address_path(address), "post" do

      assert_select "input[name=?]", "address[user_id]"

      assert_select "input[name=?]", "address[street]"

      assert_select "input[name=?]", "address[number]"

      assert_select "input[name=?]", "address[neighborhood]"

      assert_select "input[name=?]", "address[city]"

      assert_select "input[name=?]", "address[state]"

      assert_select "input[name=?]", "address[zipcode]"

      assert_select "input[name=?]", "address[country]"

      assert_select "input[name=?]", "address[primary_address]"
    end
  end
end
