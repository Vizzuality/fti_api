# frozen_string_literal: true

class ObservationsIndex
  DEFAULT_SORTING = { evidence: :asc }
  SORTABLE_FIELDS = [:evidence, :updated_at, :created_at]
  PER_PAGE = 10

  delegate :params,           to: :controller
  delegate :observations_url, to: :controller

  attr_reader :controller, :current_user

  def initialize(controller, current_user=nil)
    @controller   = controller
    @current_user = current_user
  end

  def observations
    @observations       ||= Observation.fetch_all(options_filter)
    @observations_items ||= @observations.order(sort_params)
                                         .paginate(page: current_page, per_page: per_page)
  end

  def total_items
    @total_items ||= @observations.size
  end

  def links
    {
      first: observations_url(rebuild_params.merge(first_page)),
      prev:  observations_url(rebuild_params.merge(prev_page)),
      next:  observations_url(rebuild_params.merge(next_page)),
      last:  observations_url(rebuild_params.merge(last_page))
    }
  end

  private

    def options_filter
      params.permit('id', 'sort', 'type', 'user', 'observation', 'observation' => {}).tap do |filter_params|
        filter_params[:page]= {}
        filter_params[:page][:number] = params[:page][:number] if params[:page].present? && params[:page][:number].present?
        filter_params[:page][:size]   = params[:page][:size]   if params[:page].present? && params[:page][:size].present?

        if params[:user].present? && params[:user].include?('current') && @current_user.present?
          filter_params[:user] = @current_user.id
        elsif params[:user].present? && is_number?(params[:user])
          filter_params[:user] = params[:user]
        else
          filter_params[:user] = nil
        end

        filter_params
      end
    end

    def is_number?(number)
      number.to_i.to_s == number.to_s
    end

    def current_page
      (params.to_unsafe_h.dig('page', 'number') || 1).to_i
    end

    def per_page
      (params.to_unsafe_h.dig('page', 'size') || PER_PAGE).to_i
    end

    def first_page
      { page: { number: 1 } }
    end

    def next_page
      { page: { number: [total_pages, current_page + 1].min } }
    end

    def prev_page
      { page: { number: [1, current_page - 1].max } }
    end

    def last_page
      { page: { number: total_pages } }
    end

    def total_pages
      @total_pages ||= observations.total_pages
    end

    def sort_params
      for_sort = SortParams.sorted_fields(params[:sort], SORTABLE_FIELDS, DEFAULT_SORTING)
      if params[:sort].present? && params[:sort].include?('evidence')
        new_for_sort  = "observation_translations.evidence #{for_sort['evidence']}"
        new_for_sort += ", observation.updated_at #{for_sort['updated_at']}" if params[:sort].include?('updated_at')
        new_for_sort += ", observation.created_at #{for_sort['created_at']}" if params[:sort].include?('created_at')

        for_sort = new_for_sort
      end
      for_sort
    end

    def rebuild_params
      @rebuild_params = begin
        rejected = %w(action controller)
        params.to_unsafe_h.reject { |key, value| rejected.include?(key.to_s) }
      end
    end
end
