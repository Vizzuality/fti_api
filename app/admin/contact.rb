# frozen_string_literal: true

ActiveAdmin.register Contact do
  extend BackRedirectable
  back_redirect

  menu false
  permit_params :email, :name

  filter :name, as: :select
  filter :email, as: :select
  filter :created_at

  csv do
    column :name
    column :email
    column :created_at
  end

  index do
    selectable_column
    column :name
    column :email
    column :created_at

    actions
  end
end
