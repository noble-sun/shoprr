require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'DELETE /destroy' do
    context 'when logged in user is native' do
      it 'successfully terminate session' do
        user = create(:user)
        session = create(:session, user:)

        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)

        delete session_path

        expect(Session.count).to be_zero
      end
    end

    context 'when user logged in via google authentication' do
      it 'successfully revoke google access and terminate session' do
        user = create(:user)
        create(:identity_provider, user:)
        session = create(:session, user:)

        allow(Current).to receive(:session).and_return(session)
        allow(Current).to receive(:user).and_return(user)
        allow(RevokeGoogleAccessService).to receive(:call).and_call_original

        net_httpok_double = instance_double(Net::HTTPOK, code: "200")
        allow(Net::HTTP).to receive(:post_form).and_return(net_httpok_double)

        delete session_path

        expect(Session.count).to be_zero
        expect(RevokeGoogleAccessService).to have_received(:call).with(user:)
      end

      context 'when could not revoke access due to some error' do
        it 'terminate session and log request error' do
          user = create(:user)
          create(:identity_provider, user:)
          session = create(:session, user:)

          allow(Current).to receive(:session).and_return(session)
          allow(Current).to receive(:user).and_return(user)
          allow(RevokeGoogleAccessService).to receive(:call).and_call_original
          allow(Rails.logger).to receive(:warn)

          allow(Net::HTTP).to receive(:post_form).and_return(
            Net::HTTPBadRequest.new(nil, 400, 'Bad Request')
          )

          delete session_path

          expect(Session.count).to be_zero
          expect(RevokeGoogleAccessService).to have_received(:call).with(user:)
          expect(Rails.logger).to have_received(:warn)
        end
      end
    end
  end
end
