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
#  contract_signature                  :boolean          default("false"), not null
#  required_operator_document_id       :integer          not null
#  explanation                         :text
#

class RequiredOperatorDocument < ApplicationRecord
  # include ForestTypeable
  acts_as_paranoid
  #
  # translates :explanation, touch: true
  # active_admin_translates :explanation

  belongs_to :required_operator_document_group
  belongs_to :country
  has_many :operator_documents, dependent: :destroy
  has_many :operator_document_fmus
  has_many :operator_document_countries

  validates :valid_period, numericality: { greater_than: 0 }

  validate :fixed_fields_unchanged

  before_destroy :invalidate_operator_documents, prepend: true

  scope :with_archived, -> { unscope(where: :deleted_at) }

  def invalidate_operator_documents
    self.operator_documents.find_each do |x|
      x.update(status: OperatorDocument.statuses[:doc_expired], deleted_at: Time.now)
    end
  end

  private

  def fixed_fields_unchanged
    return unless self.persisted?

    errors.add(:contract_signature, 'Cannot change the contract signature') if contract_signature_changed?
    errors.add(:forest_type, 'Cannot change the forest type') if forest_type_changed?
    errors.add(:type, 'Cannot change document type') if type_changed?
    errors.add(:country_id, 'Cannot change the country') if country_id_changed?
  end
end
