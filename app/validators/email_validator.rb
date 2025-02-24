class EmailValidator < ActiveModel::Validator
  def validate(record)
    unless valid_email_format?(record.email_address)
      record.errors.add(:email_address, "is not a valid email format")
    end

    if email_address_with_local_name_or_alias_exist?(record.email_address)
      record.errors.add(
        :email_address,
        "There's already an email with this local name registered"
      )
    end
  end

  private

  def valid_email_format?(email)
    return unless email.include?("@")

    local, domain = email.split("@")

    valid_local_name?(local) && valid_domain?(domain)
  end

  def valid_local_name?(local)
    # Oh boy... regex... I'll break down each regex here. For my sake.

    # ?! the predecessor char cannot be the next thing, so  the beginning of
    # the string '^' cannot be anything in the range '[]' of '.', '_' or '-'.
    negate_first_char = /^(?![\._\-\+])/

    # [a-z0-9] the first character must be in the range of a-z or 0-9.
    first_char = /[a-z0-9]/

    # [a-z0-9+._-] the middle of the string can now have special character like
    # '+', '.', '_' or '-'.
    alphanumeric_or_special_chars = /[a-z0-9\+\._\-]/

    # It's saying that the range of characters cannot have this range [+._-] twice in a row.
    negate_double_special_chars = /(?![\+\._\-]{2})/

    # All of this is inside (?:), so its just grouping all the expressions
    # together, but won't use as back reference like the first_char regex.
    # Because of '*', it can happen multiple times or none at all, so it doesn't
    # have to have special chars.
    middle_string = /(?:
      #{alphanumeric_or_special_chars.source}
      #{negate_double_special_chars.source}
    )*/

    # The last character  must be a simple letter or number.
    end_char = /[a-z0-9]/

    # A non-capturing group (?:) enveloping the whole local_name part.
    local_name_regex = /
      #{negate_first_char.source}
      (?:#{first_char.source}#{middle_string.source}#{end_char.source})$
    /x

    local =~ local_name_regex
  end

  def valid_domain?(domain)
    # Can only be a letter or a number.
    first_char = /[a-z0-9]/

    # It can have letter number or hyphen, but it can occur zero or many times.
    letter_num_or_hyphen = /[a-z0-9\-]*/

    # The end char before the tld can only be a letter or a number.
    end_char = /[a-z0-9]/

    # This expects a dot with at least two letters following right after, at least
    # one time. So it can be '.com' or '.com.br' for example.
    top_level_domain = /[\.[a-z]{2,}]{1,}/

    # It's defining the beginning of the string with '^', it's grouping everything
    # before the top-level-domain except the first character, and ending the string
    # with '$'.
    domain_regex = /
      ^#{first_char.source}
      (?:#{letter_num_or_hyphen.source}#{end_char.source})
      #{top_level_domain.source}$
    /x

    domain =~ domain_regex
  end

  def email_address_with_local_name_or_alias_exist?(email)
    local, domain = email.split("@")

    email_name, email_alias = local.split("+") if local.include?("+")

    user = User.where("email_address LIKE ?", "#{email_name || local}@#{domain}").or(
      User.where("email_address LIKE ?", "#{email_name || local}+%@#{domain}")
    )

    user.present?
  end
end
