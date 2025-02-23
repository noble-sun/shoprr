class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :password, format: { with: /\A(?=.{8,})/, message: "must be at least 8 characters" }
  validates :password, format: { with: /\A(?=.*\d)/, message: "must contain at least 1 digit" }
  validates :password, format: { with: /\A(?=.*[a-z])/, message: "must contain at least 1 lowercase letter" }
  validates :password, format: { with: /\A(?=.*[A-Z])/, message: "must contain at least 1 uppercase letter" }
  validates :password, format: { with: /\A(?=.*[[:^alnum:]])/, message: "must contain at least 1 symbol" }

  validates_presence_of :email_address, :cpf, :password
  validates :email_address, :cpf, uniqueness: true
  validates :cpf, length: { is: 11 }, numericality: { only_integer: true }
  validates_with CpfValidator, if: Proc.new { |user| user.cpf.present? }
  validates_with EmailValidator, if: Proc.new { |user| user.email_address.present? }
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.authenticate_by(auth)
    user = find_by("lower(email_address) = ? OR cpf = ?", auth[:login].downcase, auth[:login].gsub(/\D/, ""))
    user&.authenticate(auth[:password])
  end

  def active_cart
    carts.active.last || carts.create!
  end
end
