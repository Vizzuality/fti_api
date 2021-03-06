require 'rails_helper'

describe ObservationsImporter, type: :importer do
  let!(:country) { create(:country, iso: "DE", name: "Germany") }

  let(:importer_type) { 'observations' }
  let(:uploaded_file) { fixture_file_upload("#{importer_type}/import_data.csv", Mime[:csv].to_s) }
  let(:results) { fixture_file_upload("#{importer_type}/results.json", Mime[:json].to_s).read }
  let(:importer) { FileDataImport::BaseImporter.build(importer_type, uploaded_file) }

  context "CSV" do
    it "returns right result" do
      importer.import
      expect(importer.results.as_json).to eq(JSON.parse(results))
    end
  end
end
