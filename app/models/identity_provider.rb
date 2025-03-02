class IdentityProvider < ApplicationRecord
  belongs_to :user
  accepts_nested_attributes_for :user

  enum :name, { google: "google" }

  validates_presence_of :name, :account_identifier, :access_token, :id_token
end
