# frozen_string_literal: true
# == Schema Information
#
# Table name: observation_reports
#
#  id               :integer          not null, primary key
#  title            :string
#  publication_date :datetime
#  attachment       :string
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class ObservationReport < ApplicationRecord
  mount_base64_uploader :attachment, ObservationReportUploader
  acts_as_paranoid

  belongs_to :user, inverse_of: :observation_reports
  has_many :observation_report_observers
  has_many :observers, through: :observation_report_observers
  has_many :observations

  after_destroy :remove_attachment_id_directory

  def remove_attachment_id_directory
    FileUtils.rm_rf(File.join('public', 'uploads', 'document', 'attachment', self.id.to_s)) if self.attachment
  end

end
