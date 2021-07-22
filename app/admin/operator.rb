# frozen_string_literal: true

ActiveAdmin.register Operator, as: 'Producer' do
  extend BackRedirectable
  back_redirect

  extend Versionable
  versionate

  menu false

  config.order_clause

  actions :all
  permit_params :holding_id, :name, :fa_id, :operator_type, :country_id, :details, :concession, :is_active,
                :logo, :delete_logo, :email, fmu_ids: [],
                                             translations_attributes: [:id, :locale, :name, :details, :_destroy]

  member_action :activate, method: :put do
    resource.update(is_active: true)
    redirect_to collection_path, notice: 'Operator activated'
  end

  config.clear_action_items!

  action_item only: [:show] do
    link_to 'Edit Producer', edit_admin_producer_path(operator)
  end

  action_item only: [:show] do
    confirmation_text =
      if operator&.all_observations&.any?
        "The operator has the observations with the ids: #{operator.all_observations.pluck(:id).join(', ')}.\nIf you want to keep them associated to the operator, please archive the operator instead."
      else
        'Are you sure you want to delete the producer?'
      end
    link_to 'Delete Producer', admin_producer_path(operator), method: :delete, data: { confirm: confirmation_text }
  end

  action_item only: [:index] do
    link_to 'New Producer', new_admin_producer_path
  end

  csv do
    column :id
    column :holding_id
    column :is_active
    column :country do |operator|
      operator.country.name rescue nil
    end
    column :fa_id
    column :name
    column :email
    column :concession
    column :score_absolute do |operator|
      "#{'%.2f' % operator.score_operator_observation&.score}" rescue nil
    end
    column :obs_per_visit
    column '% Docs' do |operator|
      operator.score_operator_document&.all
    end
  end

  index do
    column 'Active?', :is_active
    column :id
    column :holding
    column :country, sortable: 'country_translations.name'
    column 'FA UUID', :fa_id
    column :name, sortable: 'operator_translations.name'
    column :email
    column :concession, sortable: true
    column 'Score', :score_absolute, sortable: 'score_absolute' do |operator|
      "#{'%.2f' % operator.score_operator_observation&.score}" rescue nil
    end
    column 'Obs/Visit', :obs_per_visit, sortable: true
    column '% Docs', :percentage_valid_documents_all, sortable: true do |operator|
      operator.score_operator_document&.all
    end
    column('Actions') do |operator|
      unless operator.is_active
        a 'Activate', href: activate_admin_producer_path(operator),
                      'data-method': :put, 'data-confirm': "Are you sure you want to ACTIVATE the operator #{operator.name}?"
      end
    end

    actions defaults: false do |operator|
      item "View", admin_producer_path(operator)
      text_node "<br/>".html_safe
      item "Edit", edit_admin_producer_path(operator)
      text_node "<br/>".html_safe
      confirmation_text =
          if operator&.all_observations&.any?
            "The operator has the observations with the ids: #{operator.all_observations.pluck(:id).join(', ')}.\nIf you want to keep them associated to the operator, please archive the operator instead."
          else
            'Are you sure you want to delete the producer?'
          end
      link_to 'Delete', admin_producer_path(operator), method: :delete, data: { confirm: confirmation_text }
    end
  end

  scope :all, default: true
  scope :active
  scope :inactive

  filter :country, as: :select,
                   collection: -> { Country.joins(:operators).with_translations(I18n.locale).order('country_translations.name') }
  filter :id,
         as: :select, label: 'Name',
         collection: Operator.with_translations(I18n.locale)
                         .order('operator_translations.name').pluck(:name, :id)
  filter :concession, as: :select


  sidebar 'Fmus', only: :show do
    attributes_table_for resource do
      ul do
        resource.fmus.collect do |fmu|
          li link_to(fmu.name, admin_fmu_path(fmu.id))
        end
      end
    end
  end

  sidebar 'Sawmills', only: :show do
    attributes_table_for resource do
      ul do
        resource.sawmills.collect do |sawmill|
          li link_to(sawmill.name, admin_sawmill_path(sawmill.id))
        end
      end
    end
  end

  sidebar 'Valid Documents', only: :show, if: proc{ resource.operator_documents.where(status: 'doc_valid').any? } do
    table_for resource.operator_documents.where(status: 'doc_valid').collect do |od|
      column('') { |od| link_to od.required_operator_document.name, admin_operator_document_path(od.id) }
    end
  end

  sidebar 'Pending Documents', only: :show, if: proc{ resource.operator_documents.where(status: 'doc_pending').any? } do
    table_for resource.operator_documents.where(status: 'doc_pending').collect do |od|
      column('') { |od| link_to od.required_operator_document.name, admin_operator_document_path(od.id) }
    end
  end

  sidebar 'Invalid Documents', only: :show,
                               if: proc{ resource.operator_documents.where(status: %w(doc_not_provided doc_invalid doc_expired)).any? } do
    table_for resource.operator_documents.where(status: %w(doc_not_provided doc_invalid doc_expired)).collect do |od|
      column('') { |od| link_to od.required_operator_document.name, admin_operator_document_path(od.id) }
    end
  end


  form do |f|
    edit = f.object.new_record? ? false : true
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Operator Details' do
      f.translated_inputs switch_locale: false do |t|
        t.input :name
        t.input :details
      end
      f.input :holding, as: :select
      f.input :email
      f.input :fa_id, as: :string, label: 'Forest Atlas UUID'
      f.input :operator_type, as: :select,
                              collection: ['Logging company', 'Artisanal', 'Community forest', 'Estate',
                                           'Industrial agriculture', 'Mining company',
                                           'Sawmill', 'Other', 'Unknown']
      f.input :country, input_html: { disabled: edit }
      f.input :concession
      f.input :logo, as: :file, hint: image_tag(f.object.logo.url(:thumbnail))
      if f.object.logo.present?
        f.input :delete_logo, as: :boolean, required: false, label: 'Remove logo'
      end
      available_fmus = Fmu.filter_by_free
      if edit
        available_fmus = []
        Fmu.filter_by_free.find_each{ |x| available_fmus << x }
        f.object.fmus.find_each{ |x| available_fmus << x }
        f.input :fmus, collection: available_fmus, input_html: { disabled: true }
      else
        f.input :fmus, collection: available_fmus
      end
      f.input :is_active
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :is_active
      row :holding
      row :name
      row :email
      row :operator_type
      row :fa_id
      row :details
      row :country
      image_row :logo
      row :address
      row :website
      row :fmus
      row :percentage_valid_documents_all do |operator|
        operator.score_operator_document&.all
      end
      row :obs_per_visit
      row :score_absolute do |operator|
        operator.score_operator_observation&.score
      end
      row :created_at
      row :updated_at
      if resource.fa_id.present?
        grouped_sod = ScoreOperatorDocument.where(operator_id: resource.id).group_by_day(:date, series: false)
        row :total_documents do
          render partial: 'score_evolution', locals: {
            scores: grouped_sod.maximum(:total)
          }
        end
        row :percentage_by_type do
          render partial: 'score_evolution', locals: {
            scores: [
              { name: 'all', data: grouped_sod.maximum(:all) },
              { name: 'per_country', data: grouped_sod.maximum(:country) },
              { name: 'per_fmus', data: grouped_sod.maximum(:fmu) }
            ]
          }
        end

        row 'Score History Table' do
          scores = ScoreOperatorDocument.where(operator_id: resource.id).order(date: :desc).to_a
          table_for ScoreOperatorDocumentDecorator.decorate_collection(scores, self) do
            column :date
            column :all
            column :fmu
            column :country
            column :total
            column :public_summary_diff do |score|
              idx = scores.index(score.model)
              prev_score = scores[idx + 1]
              score.public_summary_diff(prev_score)
            end
            column :private_summary_diff do |score|
              idx = scores.index(score.model)
              prev_score = scores[idx + 1]
              score.private_summary_diff(prev_score)
            end
            column 'Documents', &:document_history_link
          end
        end
      end
    end
    active_admin_comments
  end

  controller do
    def find_resource
      scoped_collection.unscope(:joins).with_translations.where(id: params[:id]).first!
    end
    def scoped_collection
      end_of_association_chain.with_translations(I18n.locale).includes(country: :translations)
    end
  end
end
