# == Schema Information
#
# Table name: fmu_operators
#
#  id          :integer          not null, primary key
#  fmu_id      :integer          not null
#  operator_id :integer          not null
#  current     :boolean          not null
#  start_date  :date
#  end_date    :date
#

class FmuOperator < ApplicationRecord
  include DateHelper

  belongs_to :fmu,        required: true
  belongs_to :operator,   required: true
  before_validation     :set_current_start_date
  validates_presence_of :start_date
  validate :start_date_is_earlier
  validate :one_active_per_fmu
  validate :non_colliding_dates


  # Sets the start date as today, if none is provided
  def set_current_start_date
    self.start_date = Date.today unless self.start_date.present?
  end

  # Validates if the start date is earlier than the end date
  def start_date_is_earlier
    return if end_date.blank?
    unless start_date < end_date
      errors.add(:start_date, 'Start date must be earlier than end date')
    end
  end

  # Insures only one operator is active per fmu
  def one_active_per_fmu
    return false unless fmu.present?
    unless fmu.fmu_operators.where(current: true).count <= 1
      errors.add(:current, 'There can only be one active operator at a time')
    end
  end

  # Makes sure the dates don't collide
  def non_colliding_dates
    dates = FmuOperator.where(fmu_id: self.fmu_id).pluck(:start_date, :end_date)
    dates << [self.start_date, self.end_date]

    for i in 0...(dates.count - 1)
      for j in (i + 1)...(dates.count)
        errors.add(:end_date, 'Cannot have two operators without end date') and return if dates[i][1].nil? && dates[j][1].nil?

        if intersects?(dates[i], dates[j])
          errors.add(:start_date, 'Colliding dates') and return
        end
      end
    end

    return true
  end

  # Calculates and sets all the current operator_fmus on a given day
  def self.calculate_current
    # Checks which one should be active
    to_deactivate = FmuOperator.where("current = 'TRUE' AND end_date < #{Date.today}")
    to_activate   = FmuOperator.
        where("current = 'FALSE' AND start_date <= ##{Date.today} AND (end_date = NULL OR end_date >= #{Date.today})")

    # Updates the operator documents
    to_deactivate.find_each{ |x| x.current = false; x.save! }
    to_activate.find_each{ |x| x.current = true; x.save! }
  end


end
