class AddAdicionalColumnsToUserTable < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false 
    add_column :users, :surname, :string, null: false 
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :active, :boolean, null: false, default: true
    add_column :users, :admin, :boolean, null: false, default: false
  end
end
