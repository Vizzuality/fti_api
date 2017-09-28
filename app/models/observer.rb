# frozen_string_literal: true
# == Schema Information
#
# Table name: observers
#
#  id                :integer          not null, primary key
#  observer_type     :string           not null
#  country_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_active         :boolean          default(TRUE)
#  logo              :string
#  address           :string
#  information_name  :string
#  information_email :string
#  information_phone :string
#  data_name         :string
#  data_email        :string
#  data_phone        :string
#  organization_type :string
#

class Observer < ApplicationRecord
  translates :name, :organization

  active_admin_translates :name do
    validates_presence_of :name
  end

  mount_base64_uploader :logo, LogoUploader

  belongs_to :country, inverse_of: :observers, optional: true

  has_many :observer_observations, dependent: :destroy
  has_many :observations, through: :observer_observations

  has_many :observation_report_observers
  has_many :observation_reports, through: :observation_report_observers

  has_many :users, inverse_of: :observer

  EMAIL_VALIDATOR = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validates :name, presence: true
  validates :observer_type, presence: true, inclusion: { in: %w(Mandated SemiMandated External Government),
                                                         message: "%{value} is not a valid observer type" }
  validates :organization_type,
            inclusion: { in: ['NGO', 'Academic', 'Research Institute', 'Private Company', 'Other'] }, if: :organization_type?

  validates_format_of :information_email, with: EMAIL_VALIDATOR, if: :information_email?
  validates_format_of :data_email, with: EMAIL_VALIDATOR, if: :data_email?

  scope :by_name_asc, -> {
    includes(:translations).with_translations(I18n.available_locales)
                           .order('observer_translations.name ASC')
  }

  scope :active, -> {
    where(is_active: true)
  }

  default_scope { includes(:translations) }

  class << self
    def fetch_all(options)
      observers = includes(:country, :users)
      observers
    end

    def observer_select
      by_name_asc.map { |c| ["#{c.name} (#{c.observer_type})", c.id] }
    end

    def types
      %w(Mandated SemiMandated External Government).freeze
    end

    def translated_types
      types.map { |t| [I18n.t("observer_types.#{t}", default: t), t.camelize] }
    end
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end
end
