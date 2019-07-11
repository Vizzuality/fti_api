require 'rails_helper'

RSpec.describe RequiredOperatorDocument, type: :model do
  subject(:required_operator_document) { FactoryBot.build :required_operator_document }

  it 'is valid with valid attributes' do
    expect(required_operator_document).to be_valid
  end

  it_should_behave_like 'forest_typeable', RequiredOperatorDocument

  it_should_behave_like 'translatable', FactoryBot.create(:required_operator_document), %i[explanation]

  describe 'Relations' do
    it { is_expected.to belong_to(:required_operator_document_group) }
    it { is_expected.to belong_to(:country) }
    it { is_expected.to have_many(:operator_documents).dependent(:destroy) }
    it { is_expected.to have_many(:operator_document_fmus) }
    it { is_expected.to have_many(:operator_document_countries) }
  end

  describe 'Validations' do
    it { is_expected.to validate_numericality_of(:valid_period).is_greater_than(0) }

    describe '#fixed_fields_unchanged' do
      context 'when it is persisted' do
        before do
          @required_operator_document = FactoryBot.create :required_operator_document,
            contract_signature: false,
            forest_type: 1,
            type: 'RequiredOperatorDocument'
        end

        context 'when contract_signature has changed' do
          it 'add an error on contract_signature' do
            @required_operator_document.update_attributes(contract_signature: true)

            expect(@required_operator_document.valid?).to eql false
            expect(@required_operator_document.errors[:contract_signature]).to eql(
              ['Cannot change the contract signature']
            )
          end
        end

        context 'when forest_type has changed' do
          it 'add an error on forest_type' do
            @required_operator_document.update_attributes(forest_type: 0)

            expect(@required_operator_document.valid?).to eql false
            expect(@required_operator_document.errors[:forest_type]).to eql(
              ['Cannot change the forest type']
            )
          end
        end

        context 'when type has changed' do
          it 'add an error on type' do
            @required_operator_document.update_attributes(type: 'RequiredOperatorDocumentCountry')

            expect(@required_operator_document.valid?).to eql false
            expect(@required_operator_document.errors[:type]).to eql(
              ['Cannot change document type']
            )
          end
        end

        context 'when country_id has changed' do
          it 'add an error on country_id' do
            another_country = FactoryBot.create :country
            @required_operator_document.update_attributes(country_id: another_country.id)

            expect(@required_operator_document.valid?).to eql false
            expect(@required_operator_document.errors[:country_id]).to eql(
              ['Cannot change the country']
            )
          end
        end
      end
    end
  end
end
