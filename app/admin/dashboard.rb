ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  # collection_action :deploy_portal, method: :post do
  #   system 'ls'
  #   sh 'ls'
  #   redirect_to admin_dashboard_path, notice: 'Deploying...'
  # end

  page_action :deploy_portal, method: :post do
    system 'ls'
    redirect_to admin_dashboard_path, notice: 'Deploying'
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do

    # sidebar :actions do
    # button_to "Update projects", "/admin/projects/updateprojects", :method => :post, :confirm => "Are you sure?"
    # end
    #
    # collection_action :updateprojects, :method => :post do
    #   system "rake dataspider:import_projects_ninja"
    #   redirect_to admin_dashboard_path, :notice => "Syncing..."
    # end

    columns do
      column do
        panel 'Site Management' do
          ul do
            li button_to 'Deploy Portal', '/admin/dashboard/deploy_portal', method: :post, confirm: 'Are you sure?'
            li button_to 'Deploy IM Backoffice', '/admin/dashboard/deploy_ot', method: :post, confirm: 'Are you sure?'
          end
        end
      end

      column do
        panel 'First 20 Pending Observations' do
          ul do
            Observation.Created.order(:updated_at).limit(20).map do |obs|
              li link_to(obs.details, admin_observation_path(obs))
            end
          end
        end
      end

      column do
        panel 'First 20 Pending Documents' do
          ul do
            OperatorDocument.doc_pending.order(:updated_at).limit(20).map do |od|
              li link_to("#{od.operator.name} - #{od.required_operator_document.name}", admin_operator_document_path(od))
            end
          end
        end
      end

    end
  end # content
end
