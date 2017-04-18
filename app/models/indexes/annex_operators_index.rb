# frozen_string_literal: true

class AnnexOperatorsIndex
  DEFAULT_SORTING = { illegality: :asc }
  SORTABLE_FIELDS = [:illegality, :updated_at, :created_at]
  PER_PAGE = 10

  delegate :params,              to: :controller
  delegate :annex_operators_url, to: :controller

  attr_reader :controller

  def initialize(controller)
    @controller = controller
  end

  def annex_operators
    @annex_operators ||= AnnexOperator.fetch_all(options_filter)
                                      .order(sort_params)
                                      .paginate(page: current_page, per_page: per_page)
  end

  def links
    {
      first: annex_operators_url(rebuild_params.merge(first_page)),
      prev:  annex_operators_url(rebuild_params.merge(prev_page)),
      next:  annex_operators_url(rebuild_params.merge(next_page)),
      last:  annex_operators_url(rebuild_params.merge(last_page))
    }
  end

  private

    def options_filter
      params.permit('id', 'illegality', 'sort', 'annex_operator', 'annex_operator' => {}).tap do |filter_params|
        filter_params[:page]= {}
        filter_params[:page][:number] = params[:page][:number] if params[:page].present? && params[:page][:number].present?
        filter_params[:page][:size]   = params[:page][:size]   if params[:page].present? && params[:page][:size].present?
        filter_params
      end
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
      @total_pages ||= annex_operators.total_pages
    end

    def sort_params
      for_sort = SortParams.sorted_fields(params[:sort], SORTABLE_FIELDS, DEFAULT_SORTING)
      if params[:sort].present? && params[:sort].include?('illegality')
        new_for_sort  = "annex_operator_translations.illegality #{for_sort['illegality']}"
        new_for_sort += ", annex_operators.updated_at #{for_sort['updated_at']}" if params[:sort].include?('updated_at')
        new_for_sort += ", annex_operators.created_at #{for_sort['created_at']}" if params[:sort].include?('created_at')

        for_sort = new_for_sort
      end
      for_sort
    end

    def rebuild_params
      @rebuild_params = begin
        rejected = ['action', 'controller']
        params.to_unsafe_h.reject { |key, value| rejected.include?(key.to_s) }
      end
    end
end
