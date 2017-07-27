# frozen_string_literal: true

# == Schema Information
#
# Table name: documents
#
#  id               :integer          not null, primary key
#  name             :string
#  document_type    :string
#  attachment       :string
#  attacheable_id   :integer
#  attacheable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

class Document < ApplicationRecord
  mount_base64_uploader :attachment, DocumentUploader

  belongs_to :user, inverse_of: :documents
  belongs_to :attacheable, polymorphic: true

  belongs_to :operator_document

  after_destroy :remove_attachment_id_directory
  after_create :change_operator_status

  validates :document_type, presence: true, inclusion: { in: %w(Report Doumentation),
                                                         message: "%{value} is not a valid document type" }

  scope :by_report,        -> { where(document_type: 'Report') }
  scope :by_documentation, -> { where(document_type: 'Doumentation')   }

  class << self
    def types
      %w(Report Doumentation).freeze
    end

    def types_select
      types.map { |t| [I18n.t("document_types.#{t}", default: t), t.camelize] }
    end
  end

  def remove_attachment_id_directory
    FileUtils.rm_rf(File.join('public', 'uploads', 'document', 'attachment', self.id.to_s)) if self.attachment
  end

  def change_operator_status
    attacheable.update_attributes(status: OperatorDocument.statuses[:pending]) if attacheable.is_a?(OperatorDocument)
  end
end
