class PasswordGeneratorService
  class InvalidPasswordLength < StandardError; end

  def initialize(length:, min_uppercase:, min_lowercase:, min_number:, min_symbol:)
    @length = length
    @uppercase= min_uppercase
    @lowercase = min_lowercase
    @numbers = min_number
    @symbols = min_symbol
  end

  attr_reader :length, :uppercase, :lowercase, :numbers, :symbols

  def call
    raise InvalidPasswordLength,
      "length should be greater or equal the sum of minimum characters" if
        [ uppercase, lowercase, numbers, symbols ].sum > length

    password = generate_min_characters_password

    if password.size < length
      password = complete_password_length(password)
    end

    password.shuffle.join
  end

  private

  def complete_password_length(password)
    quantity_of_chars_to_fill = length - password.size

    complete_with_chars =
      range_of_characters_to_fill_password_length.sample(
        quantity_of_chars_to_fill
      )

    password += complete_with_chars
  end

  def generate_min_characters_password
    characters_range.map do |key, value|
      value.sample(public_send(key))
    end.flatten
  end

  def range_of_characters_to_fill_password_length
    characters_range.map do |key, value|
      value unless public_send(key).zero?
    end.flatten.compact
  end

  def characters_range
    characters = {
      uppercase: ("A".."Z").to_a,
      lowercase: ("a".."z").to_a,
      numbers: ("0".."9").to_a,
      symbols: '!@#$%^&*()-_=+[]{}|;:,.<>?/'.split("")
    }
  end
end
