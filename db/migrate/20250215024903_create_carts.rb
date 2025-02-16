class CreateCarts < ActiveRecord::Migration[8.0]
  def change
    create_table :carts do |t|
      t.string :status, default: 'active', null: false
      t.decimal :price_total
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
