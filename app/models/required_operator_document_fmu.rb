# frozen_string_literal: true
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
#  deleted_at                          :datetime
#  forest_type                         :integer
#  contract_signature                  :boolean          default(FALSE), not null
#

class RequiredOperatorDocumentFmu < RequiredOperatorDocument
  include ForestTypeable
  has_many :operator_document_fmus

  validates :contract_signature, absence: true

  after_create :create_operator_document_fmus

  def create_operator_document_fmus
    fmu_attributes = { country_id: self.country_id }
    fmu_attributes[:forest_type] = self.forest_type if self.forest_type.present?

    Fmu.where(fmu_attributes).find_each do |fmu|
      if fmu.operator.present? # This is to prevent faulty situations when the fmu has no operator id
        OperatorDocumentFmu.where(required_operator_document_id: self.id,
                                  operator_id: fmu.operator.id,
                                  fmu_id: fmu.id).first_or_create do |odf|
          odf.update_attributes!(status: OperatorDocument.statuses[:doc_not_provided], current: true)
        end
      end
    end
  end
end
