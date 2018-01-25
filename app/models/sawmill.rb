# frozen_string_literal: true

# == Schema Information
#
# Table name: sawmills
#
#  id          :integer          not null, primary key
#  name        :string
#  lat         :float
#  lng         :float
#  is_active   :boolean          default(TRUE), not null
#  operator_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Sawmill < ApplicationRecord
  belongs_to :operator, optional: false
  validates :is_active, inclusion: { in: [true, false] }
  validates_numericality_of :lat, greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  validates_numericality_of :lng, greater_than_or_equal_to: -180, less_than_or_equal_to: 180

  scope :active, ->() { Sawmill.where(is_active: true) }
  scope :inactive, ->() { Sawmill.where(is_active: false) }

  after_save :update_geojson

  private

  def update_geojson
    query = "with subquery as(
                select id, json_build_object(
                'type', 'FeatureCollection',
                'features', json_agg(
                    json_build_object(
                        'type', 'Feature',
                        'id', id,
                        'geometry', ST_AsGeoJSON(ST_MakePoint(lng, lat))::json,
                       'properties', (select row_to_json(sub) from (select name, is_active, operator_id) as sub)
                        )
                    )
              ) as geojson
              from sawmills
              where id = #{self.id}
              group by id)
            update sawmills
            set geojson = subquery.geojson
            from subquery
            where subquery.id = sawmills.id;"

    ActiveRecord::Base.connection.execute(query)
  end
end
