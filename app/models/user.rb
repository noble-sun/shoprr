class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates_presence_of :email_address, :cpf, :password_digest
  validates :email_address, :cpf, uniqueness: true
  validates :cpf, length: { is: 11 }, numericality: { only_integer: true }
  validates_with CpfValidator, if: Proc.new { |model| model.cpf.present? }
  validate :email_address_format, :email_address_with_local_name_or_alias_exist

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.authenticate_by(auth)
    user = find_by("lower(email_address) = ? OR cpf = ?", auth[:login].downcase, auth[:login].gsub(/\D/, ""))
    user&.authenticate(auth[:password])
  end

  def active_cart
    carts.active.last || carts.create!
  end

  private

  EMAIL_REGEX = /^(?![._-])(?:[a-zA-Z0-9+](?:[a-zA-Z0-9+._-](?![._-]{2}))*[a-zA-Z0-9+])?@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.[a-zA-Z]{2,}$/
  def email_address_format
    unless email_address =~ EMAIL_REGEX
      errors.add(:email_address, "is not a valid email format")
    end
  end

  def email_address_with_local_name_or_alias_exist
    local, domain = email_address.split("@")

    email_name, email_alias = local.split("+") if local.include?("+")

    user = User.where("email_address LIKE ?", "#{email_name || local}@#{domain}").or(
      User.where("email_address LIKE ?", "#{email_name || local}+%@#{domain}")
    )

    if user.present?
      errors.add(:email_address, "There's already a email with this local name registered")
    end
  end
end
