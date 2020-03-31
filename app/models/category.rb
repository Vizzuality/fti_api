# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  category_type :integer
#  name          :string
#

class Category < ApplicationRecord
  # include Translatable
  enum category_type: { operator: 0, government: 1 }

  # translates :name, touch: true
  # active_admin_translates :name do
  #   validates_presence_of :name
  # end

  has_many :subcategories, dependent: :destroy

  validates :name, presence: true

  scope :by_name_asc, -> {
    includes(:translations).with_translations(I18n.available_locales)
                           .order('category_translations.name ASC')
  }

  def cache_key
    super + '-' + Globalize.locale.to_s
  end
end
