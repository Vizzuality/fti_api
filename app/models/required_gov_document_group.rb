# frozen_string_literal: true

# == Schema Information
#
# Table name: required_gov_document_groups
#
#  id                             :integer          not null, primary key
#  position                       :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  required_gov_document_group_id :integer          not null
#  name                           :string           not null
#  description                    :text
#

class RequiredGovDocumentGroup < ApplicationRecord
  # include Translatable
  #
  # translates :name, touch: true
  # translates :description
  # active_admin_translates :name do
  #   validates_presence_of :name
  # end

  validates_presence_of :position
  has_many :required_gov_documents, dependent: :destroy
end
