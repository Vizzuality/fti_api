# frozen_string_literal: true

# == Schema Information
#
# Table name: score_operator_observations
#
#  id            :integer          not null, primary key
#  date          :date             not null
#  current       :boolean          default("true"), not null
#  score         :float
#  obs_per_visit :float
#  operator_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class ScoreOperatorObservation < ApplicationRecord
  belongs_to :operator, touch: true
  validates_presence_of :date
  validates_uniqueness_of :current, scope: :operator_id, if: :current?

  scope :current, -> { where(current: true) }

  attr_accessor :visits

  # Recalculates the SOO for an operator
  # @param [Operator] operator The operator for which to recalculate the SOO
  def self.recalculate!(operator)
    return if operator.fa_id.blank?

    soo = operator.reload.score_operator_observation || ScoreOperatorObservation.new
    soo.replace(operator)
  end

  # Replaces the current SOO with a new on if there values of the SOO changed
  # @param [Operator] operator The operator for which to replace the SOO
  def replace(operator)
    soo = ScoreOperatorObservation.build(operator)
    return if self == soo && persisted?

    update!(current: false) if present? && persisted?
    soo.save!
  end

  # Builds the new SOO for an operator
  # @param [Operator] operator
  # @return [ScoreOperatorObservation] The new SOO
  def self.build(operator)
    soo = ScoreOperatorObservation.new operator: operator, date: Date.today, current: true
    soo.count_visits
    return soo if soo.visits.zero?

    soo.calculate
    soo
  end

  # Updates the number of different visits an observer has made to an operator
  # We consider "visit" as a day with observations, regardless of the number of observations on the same day
  # So if there are 3 observations for the 1st of January and 10 for the 2nd, there were 2 visits
  def count_visits
    visits_query = observations
      .joins(:observation_report)
      .select('date(observation_reports.publication_date)')
      .group('date(observation_reports.publication_date)')
      .count
    self.visits = visits_query.keys.count
  end

  def calculate
    self.obs_per_visit = observations.count.to_f / visits
    high = severity_per_visit 3
    medium = severity_per_visit 2
    low = severity_per_visit 1
    unknown = severity_per_visit 0
    self.score = (4 * high + 2 * medium + 2 * unknown + low).to_f / 9
  end

  # Syntactic sugar
  def observations
    operator.observations.unscope(:joins)
  end

  protected

  # Overrides the ==. It's now true when the score and obs_per_visit have the same value
  # @param [ScoreOperatorObservation] obj
  def ==(obj)
    obj.is_a?(self.class) && self.score == obj.score && self.obs_per_visit == obj.obs_per_visit
  end

  private

  # Returns the number of observations per visit of a given severity level
  # @param [Integer] level The level of severity
  # @return [Float] The number of observations per visit
  def severity_per_visit(level)
    observations.joins(:severity).where({ severities: { level: level } }).count.to_f / visits
  end
end
