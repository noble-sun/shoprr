class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates_presence_of :email_address, :cpf, :password_digest
  validates :email_address, :cpf, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.authenticate_by(auth)
    user = find_by("lower(email_address) = ? OR cpf = ?", auth[:login].downcase, auth[:login].gsub(/\D/, ""))
    user&.authenticate(auth[:password])
  end
end
