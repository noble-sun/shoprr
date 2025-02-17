json.extract! address, :id, :user_id, :street, :number, :neighborhood, :city, :state, :zipcode, :country, :primary_address, :created_at, :updated_at
json.url address_url(address, format: :json)
