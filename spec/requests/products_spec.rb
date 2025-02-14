require 'rails_helper'

RSpec.describe "Products", type: :request do
  describe "GET /index" do
    it 'list all products' do
      products = create_list(:product, 2)

      get "/products"

      expect(response).to have_http_status(:success)
      expect(response.body).to include(products.first.name)            
      expect(response.body).to include(products.second.name)            
    end
  end
end
