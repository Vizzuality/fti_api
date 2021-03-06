# frozen_string_literal: true

ActiveAdmin.register Tool do
  extend BackRedirectable
  back_redirect

  menu false

  config.order_clause


  permit_params :position, translations_attributes: [:id, :locale, :name, :description, :_destroy]

  filter :position, as: :select
  filter :name

  index do
    column :position
    column :name
    column :description

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'How To Details' do
      f.input :position
      f.translated_inputs switch_locale: false do |t|
        t.input :name
        t.input :description,
                as: :quill_editor,
                input_html: {
                  data: {
                    options: {
                      modules: {
                        toolbar: [['bold', 'italic', 'underline'],
                                  ['link', 'video']]
                      },
                      placeholder: 'Type something...',
                      theme: 'snow'
                    }
 }
 }
      end
    end
    f.actions
  end


  show do
    attributes_table do
      row :position
      row :name
      row :description
    end

    active_admin_comments
  end

end
