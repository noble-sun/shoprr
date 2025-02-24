class CpfValidator < ActiveModel::Validator
  def validate(record)
    cpf = record.cpf
    first_verification_digit = validate_verification_digit(
      valid_partial_cpf: cpf.first(9), verification_digit: cpf.at(9)
    )
    second_verification_digit = validate_verification_digit(
      valid_partial_cpf: cpf.first(10), verification_digit: cpf.last
    )

    unless first_verification_digit && second_verification_digit
      record.errors.add(:cpf, "invalid verification digit")
    end
  end

  private

  def validate_verification_digit(valid_partial_cpf:, verification_digit:)
    remainder =
      valid_partial_cpf.reverse.split(//).map.with_index(2) do |char, index|
        char.to_i * index
      end.sum % 11

    valid_verification_digit = 0
    unless remainder.equal?(0) || remainder.equal?(1)
      valid_verification_digit = 11 - remainder
    end

    verification_digit.to_i == valid_verification_digit
  end
end
