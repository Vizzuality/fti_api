
module V1
  class ObservationFiltersController < ApiController
    include ErrorSerializer

    skip_before_action :authenticate

    def index
      language = params['locale'].present? ? params['locale'] : 'en'
      I18n.locale = language

      types = [{id: 'operator', name: 'Operator'}, {id: 'government', name: 'Government'}]
      country_ids = Country.with_observations.joins(:translations)
                        .map{|x| {id: x.id, iso: x.iso, name: x.name}}.sort_by { |c| c[:name] }
      fmu_ids = Fmu.all.joins(:translations).map{|x| {id: x.id, name: x.name }}
      years = Observation.pluck(:publication_date).map{|x| x.year}.uniq.sort
                  .map{ |x| {id: x, name: x }}
      observer_ids = Observer.all.includes(:translations).map{|x| {id: x.id, name: x.name }}
      category_ids = Category.all.includes(:translations).map{ |x| { id: x.id, name: x.name } }
      severities =[{id: 0, name: 'Unknown'}, {id: 1, name: 'Low'}, {id: 2, name: 'Medium'}, {id: 3, name: 'High'}]

      filters = {
          'observation_type': types,
          'country_id': country_ids,
          'fmu_id': fmu_ids,
          'years': years,
          'observer_id': observer_ids,
          'category_id': category_ids,
          'severity_level': severities
      }.to_json

      render json: filters
    end

  end
end
