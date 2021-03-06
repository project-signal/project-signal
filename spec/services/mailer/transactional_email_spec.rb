require 'rails_helper'
require 'shared/stripe'

describe TransactionalEmail do
  describe '#send' do
    let(:brand)          { identity.brand }
    let(:email)          { 'test@signalplus.co' }
    let!(:identity)      { create(:identity) }
    let!(:subscription)  { create(:subscription, brand: brand)}

    before(:each) do
      allow(Mandrill::API).to receive(:new).and_call_original
    end

    context 'welcome email' do
    # EXAMPLE RESPONSE
    # [
    #  {"email"=>"eddyfabery@gmail.com",
    #   "status"=>"sent",
    #   "_id"=>"86566aed99df4dbdbcfd197da7fb9b04",
    #   "reject_reason"=>nil}
    # ]

      it 'sends welcome email template' do
        VCR.use_cassette 'mandrill_response' do
          response = described_class.welcome(brand, email).send
          expect(response[0]['reject_reason']).to be_nil
        end
      end
    end
  end
end
