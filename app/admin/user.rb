ActiveAdmin.register User do
  menu parent: 'User Management', priority: 1
  permit_params :email, :password, :password_confirmation, :country_id,
                :institution, :name, :nickname, :web_url, :is_active,
                :observer_id, :operator_id,
                user_permission_attributes: [:user_role]

  filter :name, as: :select
  filter :nickname, as: :select
  filter :email, as: :select
  filter :current_sign_in_at
  filter :created_at

  controller do
    def scoped_collection
      User.where.not(email: 'webuser@example.com').includes([country: :translations], :user_permission)
    end
  end

  controller do
    def update
      model = :user

      if params[model][:password].blank?
        %w(password password_confirmation).each { |p| params[model].delete(p) }
      end

      super
    end
  end

  index do
    column('Activation') do |user|
      if user.id != current_user.id
        if user.is_active
          a 'Deactivate', href: deactivate_admin_user_path(user),  'data-method': :put,
            onclick: "return confirm('Are you sure you want to activate user #{user.name}')"
        else
          a 'Activate', href: activate_admin_user_path(user),      'data-method': :put,
            onclick: "return confirm('Are you sure you want to deactivate user #{user.name}')"
        end
      end
    end
    column :is_active
    column 'Role', :user_permission do |user|
      user.user_permission.user_role if user.user_permission
    end
    column :name
    column :nickname
    column :email
    column :observer
    column :operator
    column :current_sign_in_at
    column :sign_in_count

    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Admin Details' do
      f.inputs for: [:user_permission, f.object.user_permission || UserPermission.new] do |p|
        p.input :user_role, as: :select, collection: UserPermission.user_roles.keys, include_blank: false
      end
      f.input :observer
      f.input :operator
      f.input :country
      f.input :name
      f.input :nickname
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :web_url
      f.input :is_active
    end
    f.actions
  end

  member_action :activate, method: :put do
    resource.update_attributes(is_active: true) unless resource.id == current_user.id
    redirect_to collection_path, notice: 'User activated'
  end

  member_action :deactivate, method: :put do
    resource.update_attributes(is_active: false) unless (resource.id == current_user.id) || (resource.email == 'webuser@example.com')
    redirect_to collection_path, notice: 'User deactivated'
  end
end
