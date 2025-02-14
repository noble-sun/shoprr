class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :quantity, null: false
      t.decimal :price, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end

    execute "ALTER TABLE products ADD CONSTRAINT price_must_be_positive CHECK (price >= 0);"
    execute "ALTER TABLE products ADD CONSTRAINT quantity_must_be_positive CHECK (quantity >= 0);"
  end
end
