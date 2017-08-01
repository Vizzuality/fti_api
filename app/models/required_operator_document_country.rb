# == Schema Information
#
# Table name: required_operator_documents
#
#  id                                  :integer          not null, primary key
#  type                                :string
#  required_operator_document_group_id :integer
#  name                                :string
#  country_id                          :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  valid_period                        :integer
#

class RequiredOperatorDocumentCountry < RequiredOperatorDocument
  has_many :operator_document_countries

  after_create :create_operator_document_countries

  def create_operator_document_countries
    Operator.where(country_id: self.country_id).find_each do |operator|
      OperatorDocumentCountry.where(required_operator_document_id: self.id, operator_id: operator.id).first_or_create do |odc|
        odc.update_attributes!(status: OperatorDocument.statuses[:doc_not_provided])
      end
    end
  end


end
