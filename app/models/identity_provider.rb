class IdentityProvider < ApplicationRecord
  belongs_to :user

  enum :name, { google: 'google' }

  validates_presence_of :name, :account_identifier
end
