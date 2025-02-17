class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :street
      t.integer :number
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :zipcode
      t.string :country
      t.boolean :primary_address

      t.timestamps
    end
  end
end
