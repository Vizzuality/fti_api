# frozen_string_literal: true

module V1
  class ImportsController < ApiController
    authorize_resource :file_data_import

    def create
      importer.import

      render json: importer.results
    end

    private

    def importer_type
      params.fetch(:importer_type)
    end

    def import_params
      params.fetch(:import).permit(:importer_type, :file)
    end

    def importer
      @importer ||= FileDataImport::BaseImporter.build(import_params[:importer_type], import_params[:file])
    end

    def set_locale
      I18n.locale = :en
    end
  end
end
