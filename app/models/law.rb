# == Schema Information
#
# Table name: laws
#
#  id                 :integer          not null, primary key
#  written_infraction :text
#  infraction         :text
#  sanctions          :text
#  min_fine           :integer
#  max_fine           :integer
#  penal_servitude    :string
#  other_penalties    :text
#  apv                :text
#  subcategory_id     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  country_id         :integer
#  currency           :string
#

class Law < ApplicationRecord
  belongs_to :subcategory,  required: true
  belongs_to :country,      required: true
  has_many   :observations, inverse_of: :laws

  validates :min_fine, numericality: { greater_than_or_equal_to: 0 }, if: :min_fine?
  validates :max_fine, numericality: { greater_than_or_equal_to: 0 }, if: :max_fine?
end
