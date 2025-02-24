class PasswordValidator < ActiveModel::Validator
  def validate(record)
    requirements = {
      /\A(?=.*\d)/ => "must contain at least 1 digit",
      /\A(?=.*[a-z])/ =>"must contain at least 1 lowercase letter",
      /\A(?=.*[A-Z])/ =>"must contain at least 1 uppercase letter",
      /\A(?=.*[[:^alnum:]])/ =>"must contain at least 1 symbol"
    }

    requirements.each do |regex, message|
      unless record.password.match?(regex)
        record.errors.add(:password, message)
      end
    end
  end
end
