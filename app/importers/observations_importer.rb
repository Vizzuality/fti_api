# frozen_string_literal: true

class ObservationsImporter < FileDataImport::BaseImporter
  PERMITTED_ATTRIBUTES = %i[
    observation_type publication_date pv is_active location_accuracy
    lat lng fmu_id evidence_type location_information actions_taken
    validation_status is_physical_place
  ].freeze

  PERMITTED_TRANSLATES = %i[
    details evidence concern_opinion litigation_status
  ].freeze

  USER_PERMITTED_ATTRIBUTES = %i[
    name email nickname institution is_active deactivated_at
    web_url permissions_request permissions_accepted
  ].freeze


  record Observation, permitted_attributes: PERMITTED_ATTRIBUTES, permitted_translations: PERMITTED_TRANSLATES

  belongs_to Country, permitted_attributes: %i[iso],  permitted_translations: %i[name], required: true
  belongs_to Severity, permitted_attributes: %i[level], permitted_translations: %i[details]
  belongs_to Government, permitted_attributes: %i[is_active], permitted_translations: %i[government_entity details]
  belongs_to ObservationReport, permitted_attributes: %i[title publication_date created_at updated_at attachment]
  belongs_to User, permitted_attributes: USER_PERMITTED_ATTRIBUTES
  belongs_to User, as: :modified_user, permitted_attributes: USER_PERMITTED_ATTRIBUTES

  belongs_to Subcategory, permitted_attributes: %i[subcategory_type category_id location_required],
                          permitted_translations: %i[name details]

  belongs_to Law,
             permitted_attributes: %i[
               written_infraction infraction sanctions min_fine max_fine
               penal_servitude other_penalties apv complete currency
             ]

  belongs_to Fmu,
             permitted_attributes: %i[
               geojson forest_type certification_fsc certification_pefc
               certification_olb certification_vlc certification_vlo certification_tltv
             ],
             permitted_translations: %i[name]

  belongs_to Operator,
             permitted_attributes: %i[approved operator_type concession is_active logo website address delete_logo],
             permitted_translations: %i[name details], can: %i[create]
end
