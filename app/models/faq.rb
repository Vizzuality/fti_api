# frozen_string_literal: true

# == Schema Information
#
# Table name: faqs
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image      :string
#  question   :string
#  answer     :text
#

class Faq < ApplicationRecord
  # include Translatable
  # translates :question, :answer, touch: true

  mount_base64_uploader :image, PhotoUploader
  attr_accessor :delete_image

  before_validation { self.remove_image! if self.delete_image == '1' }
  validates_uniqueness_of :position
  validates_presence_of :position

  # active_admin_translates :question do
  #   validates_presence_of :question
  # end
  #
  # active_admin_translates :answer do
  #   validates_presence_of :answer
  # end
end
