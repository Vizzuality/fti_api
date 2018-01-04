# frozen_string_literal: true

# == Schema Information
#
# Table name: subcategories
#
#  id               :integer          not null, primary key
#  category_id      :integer
#  subcategory_type :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Subcategory < ApplicationRecord
  include Translatable
  enum subcategory_type: { operator: 0, government: 1 }
  translates :name, :details, touch: true

  active_admin_translates :name do; end

  belongs_to :category
  has_many :severities, dependent: :destroy
  has_many :observations, inverse_of: :subcategory, dependent: :destroy
  has_many :laws, inverse_of: :subcategory

  default_scope do
    includes(:translations)
  end
end
