
module V1
  class ObservationFiltersController < ApplicationController
    include ErrorSerializer
    include ApiUploads

    skip_before_action :authenticate

    def index
      annexes = [{id: 'AnnexOperator', name: 'Operator'}, {id: 'AnnexGovernance', name: 'Governance'}]
      countries = Country.all.includes(:translations).with_translations(I18n.available_locales).pluck(:id, :iso, :name)
        .map{|x| {id: x[0], iso: x[1], name: x[2]}}
      fmus = Fmu.all.includes(:translations).with_translations(I18n.available_locales).pluck(:id, :name)
        .map{|x| {id: x[0], name: x[1]}}
      years = Observation.pluck(:publication_date).map{|x| x.year}.uniq.sort
        .map{ |x| {id: x, name: x }}
      monitors = Observer.all.includes(:translations).with_translations(I18n.available_locales).pluck(:id, :name)
        .map{|x| {id: x[0], name: x[1]}}
      categories = Category.all.includes(:translations).with_translations(I18n.available_locales).pluck(:id, :name)
        .map{|x| {id: x[0], name: x[1]}}
      #levels = Severity.all.includes(:translations).with_translations(I18n.available_locales).pluck(:level).sort
      levels =[{id: 0, name: 'Unknown'}, {id: 1, name: 'Low'}, {id: 2, name: 'Medium'}, {id: 3, name: 'High'}]

      filters = {
          'type': annexes,
          'country': countries,
          'fmu': fmus,
          'years': years,
          'monitors': monitors,
          'categories': categories,
          'levels': levels
      }.to_json

      render json: filters
    end

  end
end
