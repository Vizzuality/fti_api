ActiveAdmin.register Observation do

  actions :all, except: [:new, :create]
  permit_params :name


  member_action :approve, method: :put do
    resource.update_attributes(validation_status: Observation.validation_statuses['Approved'])
    redirect_to resource_path, notice: 'Document approved'
  end

  member_action :reject, method: :put do
    resource.update_attributes(validation_status: Observation.validation_statuses['Rejected'])
    redirect_to resource_path, notice: 'Document rejected'
  end

  member_action :start_review, method: :put do
    resource.update_attributes(validation_status: Observation.validation_statuses['Under revision'])
    redirect_to resource_path, notice: 'Document under revision'
  end


  batch_action :approve, confirm: 'Are you sure you want to approve all this observations?' do |ids|
    batch_action_collection.find(ids).each do |observation|
      observation.update_attributes(validation_status: Observation.validation_statuses['Approved'])
    end
    redirect_to collection_path, notice: 'Documents approved!'
  end

  batch_action :reject, confirm: 'Are you sure you want to reject all this observations?' do |ids|
    batch_action_collection.find(ids).each do |observation|
      observation.update_attributes(validation_status: Observation.validation_statuses['Rejected'])
    end
    redirect_to collection_path, notice: 'Documents rejected!'
  end

  batch_action :under_revision, confirm: 'Are you sure you want to put all this observations under revision?' do |ids|
    batch_action_collection.find(ids).each do |observation|
      observation.update_attributes(validation_status: Observation.validation_statuses['Under Revision'])
    end
    redirect_to collection_path, notice: 'Documents put under revision!'
  end

  scope :all, default: true
  scope :operator
  scope :government

  index do
    selectable_column
    tag_column 'Status', :validation_status, sortable: true
    column :country
    column :fmu
    column :operator
    column :subcategory
    column :severity do |o|
      o.severity.level
    end
    column :publication_date, sortable: true
    column 'Active?', :is_active
    column('Approve') { |observation| link_to 'Approve', approve_admin_observation_path(observation), method: :put}
    column('Reject') { |observation| link_to 'Reject', reject_admin_observation_path(observation), method: :put}
    column('Review') { |observation| link_to 'Review', start_review_admin_observation_path(observation), method: :put}
    actions
  end

  filter :validation_status
  filter :country
  filter :observation_type, as: :select
  filter :operator
  filter :is_active
  filter :updated_at


  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Country Details' do
      f.input :country, input_html: { disabled: true }
      f.input :observation_type, input_html: { disabled: true }
      f.input :subcategory, input_html: { disabled: true }
      f.input :severity, as: :select,
              collection: Severity.all.map {|s| ["#{s.level} - #{s.details.first(80)}", s.id]},
              input_html: { disabled: true }
      f.input :fmu, input_html: { disabled: true }
      f.input :observer, input_html: { disabled: true }
      f.input :government, as: :select,
              collection: Government.all.map {|g| [g.government_entity, g.id] },
              input_html: { disabled: true } if f.object.observation_type == 'government'
      f.input :operator, input_html: { disabled: true } if f.object.observation_type == 'operator'
      f.input :publication_date, as: :date_picker
      f.input :pv
      f.input :lat
      f.input :lng
      f.input :validation_status
      f.input :is_active
    end
    f.inputs 'Translated fields' do
      f.translated_inputs switch_locale: false do |t|
        t.input :details
        t.input :evidence
        t.input :concern_opinion
        t.input :litigation_status
      end
    end
    f.actions
  end
end