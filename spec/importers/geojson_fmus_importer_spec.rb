require 'rails_helper'

describe GeojsonFmusImporter, type: :importer do
  let!(:country) { create(:country, iso: "CMR", name: "Cameroon") }
  let!(:fmu) { create(:fmu, id: 100187, name: "asdf", forest_type: 2, country: country) }

  let(:importer_type) { "geojson_fmus" }
  let(:uploaded_file) { fixture_file_upload("#{importer_type}/import_data.zip") }
  let(:results) { fixture_file_upload("#{importer_type}/results.json", Mime[:json].to_s).read }
  let(:importer) { FileDataImport::BaseImporter.build(importer_type, uploaded_file) }

  context "ZIP with Esri shape files" do
    it "returns right result" do
      importer.import
      expect(importer.results.as_json).to eq(JSON.parse(results))
    end
  end
end
