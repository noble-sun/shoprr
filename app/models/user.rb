class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  has_one :identity_provider

  validates_presence_of :email_address, :password, :name, :surname
  validates :phone, numericality: { only_integer: true }, length: { is: 11 }, if: -> { phone.present? }

  with_options if: -> { password.present? } do
    validates :password, length: { minimum: 8 }
    validates_with PasswordValidator
  end

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  with_options if: -> { email_address.present? } do
    validates :email_address, uniqueness: true
    validates_with EmailValidator
  end

  with_options if: -> { identity_provider.nil? } do
    validates :cpf,
      presence: true,
      uniqueness: true,
      length: { is: 11 },
      numericality: { only_integer: true }
    validates_with CpfValidator
  end

  def self.authenticate_by(auth)
    user = find_by("lower(email_address) = ? OR cpf = ?", auth[:login].downcase, auth[:login].gsub(/\D/, ""))
    user&.authenticate(auth[:password])
  end

  def active_cart
    carts.active.last || carts.create!
  end
end
