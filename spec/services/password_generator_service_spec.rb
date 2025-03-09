require 'rails_helper'

RSpec.describe PasswordGeneratorService, type: :service do
  describe '#call' do
    context 'generate a randomized password' do
      context 'with all characters' do
        it 'successfully' do
          password = described_class.call(
            length: 10,
            min_uppercase: 2,
            min_lowercase: 2,
            min_number: 2,
            min_symbol: 2,
          )

          expect(password.length).to eq(10)

          # (?:) groups the the matcher but does not capture the string that matched with to be used later
          # [^a-z]* is anything that is not a lowecase char. '*' indicates it can have 0 or more times
          # [a-z] matches one single lowercase.
          # {2,} the group need to match a least 2 times.
          expect(password).to match(/(?:[^a-z]*[a-z]){2,}/)
          expect(password).to match(/(?:[^A-Z]*[A-Z]){2,}/)
          expect(password).to match(/(?:[^0-9]*[0-9]){2,}/)
          expect(password).to match(/(?:[^[:^alnum:]]*[[:^alnum:]]){2,}/)
        end
      end

      context 'only without uppercase characters' do
        it 'successfully' do
          password = described_class.call(
            length: 6,
            min_uppercase: 0,
            min_lowercase: 2,
            min_number: 2,
            min_symbol: 2,
          )

          expect(password.length).to eq(6)
          expect(password).to match(/[^A-Z]/)
          expect(password).to match(/(?:[^a-z]*[a-z]){2,}/)
          expect(password).to match(/(?:[^0-9]*[0-9]){2,}/)
          expect(password).to match(/(?:[^[:^alnum:]]*[[:^alnum:]]){2,}/)
        end
      end

      context 'only without lowercase characters' do
        it 'successfully' do
          password = described_class.call(
            length: 10,
            min_uppercase: 2,
            min_lowercase: 0,
            min_number: 2,
            min_symbol: 2,
          )

          expect(password.length).to eq(10)
          expect(password).to match(/[^a-z]/)
          expect(password).to match(/(?:[^A-Z]*[A-Z]){2,}/)
          expect(password).to match(/(?:[^0-9]*[0-9]){2,}/)
          expect(password).to match(/(?:[^[:^alnum:]]*[[:^alnum:]]){2,}/)
        end
      end

      context 'only without numbers' do
        it 'successfully' do
          password = described_class.call(
            length: 10,
            min_uppercase: 2,
            min_lowercase: 2,
            min_number: 0,
            min_symbol: 2,
          )

          expect(password.length).to eq(10)
          expect(password).to match(/[^0-9]/)
          expect(password).to match(/(?:[^a-z]*[a-z]){2,}/)
          expect(password).to match(/(?:[^A-Z]*[A-Z]){2,}/)
          expect(password).to match(/(?:[^[:^alnum:]]*[[:^alnum:]]){2,}/)
        end
      end

      context 'only without symbols' do
        it 'successfully' do
          password = described_class.call(
            length: 10,
            min_uppercase: 2,
            min_lowercase: 2,
            min_number: 2,
            min_symbol: 0,
          )

          expect(password.length).to eq(10)
          expect(password).to match(/[^[:^alnum:]]/)
          expect(password).to match(/(?:[^a-z]*[a-z]){2,}/)
          expect(password).to match(/(?:[^A-Z]*[A-Z]){2,}/)
          expect(password).to match(/(?:[^0-9]*[0-9]){2,}/)
        end
      end
    end

    context 'when length is less than the sum of minimum character types specified' do
      it 'do not generate password' do
        expect { described_class.call(
          length: 5,
          min_uppercase: 2,
          min_lowercase: 2,
          min_number: 2,
          min_symbol: 2,
        ) }.to raise_error(
          PasswordGeneratorService::InvalidPasswordLength
        ).with_message('length should be greater or equal the sum of minimum characters')
      end
    end
  end
end
