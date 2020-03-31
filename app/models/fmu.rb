# frozen_string_literal: true

# == Schema Information
#
# Table name: fmus
#
#  id                   :integer          not null, primary key
#  country_id           :integer
#  geojson              :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  certification_fsc    :boolean          default("false")
#  certification_pefc   :boolean          default("false")
#  certification_olb    :boolean          default("false")
#  certification_pafc   :boolean          default("false")
#  certification_fsc_cw :boolean          default("false")
#  certification_tlv    :boolean          default("false")
#  forest_type          :integer          default("0"), not null
#  geometry             :geometry         geometry, 0
#  properties           :jsonb
#  deleted_at           :datetime
#  certification_ls     :boolean          default("false")
#  name                 :string
#

class Fmu < ApplicationRecord
  acts_as_paranoid

  include ValidationHelper
  # include Translatable
  include ForestTypeable
  # translates :name, touch: true

  attr_reader :esri_shapefiles_zip

  # active_admin_translates :name do
  #   validates_presence_of :name
  # end

  belongs_to :country, inverse_of: :fmus
  has_many :observations, inverse_of: :fmu, dependent: :destroy
  has_many :active_observations, ->{ active }, class_name: 'Observation'

  has_many :fmu_operators, inverse_of: :fmu, dependent: :destroy
  has_many :operators, through: :fmu_operators
  has_one :fmu_operator, ->{ where(current: true) }
  has_one :operator, through: :fmu_operator

  has_many :operator_document_fmus

  accepts_nested_attributes_for :operators

  validates :country_id, presence: true
  validates :name, presence: true
  validates :forest_type, presence: true

  before_save :update_geojson
  after_save :update_geometry, if: :geojson_changed?
  before_destroy :really_destroy_documents

  default_scope { includes(:translations) }

  # TODO Redo all of those
  scope :filter_by_countries,      ->(country_ids)  { where(country_id: country_ids.split(',')) }
  scope :filter_by_operators,      ->(operator_ids) { joins(:fmu_operators).where(fmu_operators: { current: true, operator_id: operator_ids.split(',') }) }
  # this could also be done like: "id not in ( select fmu_id from fmu_operators where \"current\" = true)"
  # but it might break the method chaining
  scope :filter_by_free,            ->            { where.not(id: FmuOperator.where(current: :true).pluck(:fmu_id)).group(:id) }
  scope :with_certification_fsc,    ->            { where certification_fsc:     true }
  scope :with_certification_pefc,   ->            { where certification_pefc:    true }
  scope :with_certification_olb,    ->            { where certification_olb:     true }
  scope :with_certification_pafc,   ->            { where certification_pafc:    true }
  scope :with_certification_fsc_cw, ->            { where certification_fsc_cw:  true }
  scope :with_certification_tlv,    ->            { where certification_tlv:     true }
  scope :with_certification_ls,     ->            { where certification_ls:      true }
  scope :current,                   ->            { joins(:fmu_operators).where(fmu_operators: { current: true }) }

  class << self
    def fetch_all(options)
      country_ids  = options['country_ids'] if options.present? && options['country_ids'].present? && ValidationHelper.ids?(options['country_ids'])
      operator_ids  = options['operator_ids'] if options.present? && options['operator_ids'].present? && ValidationHelper.ids?(options['operator_ids'])
      free = options.present? && options['free'] == 'true'

      fmus = includes([:country, :operator])
      fmus = fmus.filter_by_countries(country_ids) if country_ids.present?
      fmus = fmus.filter_by_operators(operator_ids) if operator_ids.present?
      fmus = fmus.filter_by_free if free
      fmus
    end

    # Returns a vector tile for the X,Y,Z provided
    def vector_tiles(param_z, param_x, param_y)
      begin
        x, y, z = Integer(param_x), Integer(param_y), Integer(param_z)
      rescue ArgumentError, TypeError
        return nil
      end

      query =
          <<~SQL
            SELECT ST_ASMVT(tile.*, 'layer0', 4096, 'mvtgeometry', 'id') as tile
             FROM (SELECT id, properties, ST_AsMVTGeom(the_geom_webmercator, ST_TileEnvelope(#{z},#{x},#{y}), 4096, 256, true) AS mvtgeometry
                                      FROM (select *, st_transform(geometry, 3857) as the_geom_webmercator from fmus) as data
                                    WHERE ST_AsMVTGeom(the_geom_webmercator, ST_TileEnvelope(#{z},#{x},#{y}),4096,0,true) IS NOT NULL) AS tile;
          SQL

      tile = ActiveRecord::Base.connection.execute query
      ActiveRecord::Base.connection.unescape_bytea tile.getvalue(0, 0)
    end
  end

  def esri_shapefiles_zip=(esri_shapefiles_zip)
    FileDataImport::Parser::Zip.new(esri_shapefiles_zip.path).foreach_with_line do |attributes, index|
      # takes only the first feature from the Esri shapefile.
      self.geojson = attributes[:geojson].slice("type", "geometry").merge("properties" => {})
      break
    end

    @esri_shapefiles_zip = esri_shapefiles_zip
  end

  def update_geojson
    temp_geojson = self.geojson
    return if temp_geojson.blank?

    temp_geojson['properties']['id'] = self.id
    temp_geojson['properties']['fmu_name'] = self.name
    temp_geojson['properties']['company_na'] = self.operator.name if self.operator.present?
    temp_geojson['properties']['operator_id'] = self.operator.id if self.operator.present?
    temp_geojson['properties']['certification_fsc'] = self.certification_fsc
    temp_geojson['properties']['certification_pefc'] = self.certification_pefc
    temp_geojson['properties']['certification_olb'] = self.certification_olb
    temp_geojson['properties']['certification_pafc'] = self.certification_pafc
    temp_geojson['properties']['certification_fsc_cw'] = self.certification_fsc_cw
    temp_geojson['properties']['certification_tlv'] = self.certification_tlv
    temp_geojson['properties']['certification_ls'] = self.certification_ls
    temp_geojson['properties']['observations'] = self.active_observations.reload.uniq.count
    temp_geojson['properties']['fmu_type_label'] = Fmu::FOREST_TYPES[self.forest_type.to_sym][:geojson_label] rescue ''

    self.geojson = temp_geojson
  end

  def update_geometry
    query =
      <<~SQL
        WITH g as (
        SELECT *, x.properties as prop, ST_GeomFromGeoJSON(x.geometry) as the_geom
        FROM fmus CROSS JOIN LATERAL
        jsonb_to_record(geojson) AS x("type" TEXT, geometry jsonb, properties jsonb )
        )
        update fmus
        set geometry = g.the_geom , properties = g.prop
        from g
        where fmus.id = g.id;
      SQL

    ActiveRecord::Base.connection.execute query
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  # Methods for Active Admin

  ransacker :operator,
            formatter: proc { |operator_ids|
              matches = Fmu.filter_by_operators(operator_ids).map(&:id)
              matches.any? ? matches : nil
            } do |parent|
    parent.table[:id]
  end

  private

  def really_destroy_documents
    mark_for_destruction # Hack to work with the hard delete of operator documents
    ActiveRecord::Base.connection.execute("DELETE FROM operator_documents WHERE fmu_id = #{id}")
  end
end
