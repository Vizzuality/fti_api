require 'rails_helper'

RSpec.describe MailService do
  context '#notify_operator_expired_document' do
    let(:country) { FactoryBot.create(:country)}
    let(:operator) { FactoryBot.create(:operator, country_id: country.id, email: 'test@mail.com')}
    let(:rod1) { FactoryBot.create(:required_operator_document_country, country_id: country.id)}
    let(:rod2) { FactoryBot.create(:required_operator_document_country, country_id: country.id)}
    let(:document1) { FactoryBot.create(:operator_document_country, required_operator_document_id: rod1.id,
                                        operator_id: operator, expire_date: Date.today)}
    let(:document2) { FactoryBot.create(:operator_document_country, required_operator_document_id: rod2.id,
                                        operator_id: operator, expire_date: Date.today)}

    context 'Has documents expiring today' do
      it 'Should send an email listing the two documents expiring today' do
        mail = MailService.new.notify_operator_expired_document(operator, [document1, document2])
        expect(mail.to).to eq('test@mail.com')
        expect(mail.subject).to eq('You have 2 documents expiring in 1 day')
        expect(mail.body).to eq("The following documents are going to expire:\n\\n#{rod1.name}\\n#{rod2.name}\\nBest,\nOTP Team")
      end
    end
  end
end