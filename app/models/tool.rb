# frozen_string_literal: true

# == Schema Information
#
# Table name: tools
#
#  id          :integer          not null, primary key
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  name        :string
#  description :text
#

class Tool < ApplicationRecord
  # translates :name, :description
  # active_admin_translates :name, :description
end
