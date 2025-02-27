class CreateIdentityProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :identity_providers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :account_identifier, null: false

      t.timestamps
    end

    add_index :identity_providers, :account_identifier
  end
end
