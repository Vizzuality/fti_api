# frozen_string_literal: true

# == Schema Information
#
# Table name: annex_documents
#
#  id                         :integer          not null, primary key
#  documentable_type          :string           not null
#  documentable_id            :integer          not null
#  operator_document_annex_id :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
class AnnexDocument < ApplicationRecord
  belongs_to :documentable, polymorphic: true
  belongs_to :operator_document_annex

  # An annex can only belong to one Operator Document
  # validates_uniqueness_of :documentable_id,
  #                         conditions: -> { where(documentable_type: 'OperatorDocument') },
  #                         scope: :operator_document_annex_id

  # # A Documentable cannot have the same annex more than once
  # validates_uniqueness_of :operator_document_annex_id,
  #                         scope: [:documentable_type, :documentable_id]
end
