ActiveAdmin.register_page 'Access Control' do
  menu parent: 'User Management', priority: 2

  page_action :edit do
  end

  controller do
    def index
      render layout: 'active_admin'
    end

    def edit
      @up = User.find(params['format']).user_permission
      render layout: 'active_admin'
    end
  end
end