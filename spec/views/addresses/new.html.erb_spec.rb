require 'rails_helper'

RSpec.describe "addresses/new", type: :view do
  before(:each) do
    assign(:address, Address.new(
      user: nil,
      street: "MyString",
      number: 1,
      neighborhood: "MyString",
      city: "MyString",
      state: "MyString",
      zipcode: "MyString",
      country: "MyString",
      primary_address: false
    ))
  end

  it "renders new address form" do
    render

    assert_select "form[action=?][method=?]", addresses_path, "post" do

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
