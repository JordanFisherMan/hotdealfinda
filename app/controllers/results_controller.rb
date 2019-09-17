class ResultsController < ApplicationController
  include ApplicationHelper

  def results
    fetch
    @search = {
      present: params[:search].present?,
      title: 'Search',
      query: params[:search] || ''
    }
    @category = {
      present: params[:category].present?,
      title: 'Category',
      query: category_query
    }
    if params[:search].present? && params[:search] != ''
      @deals = @deals.where("title ILIKE '%#{params[:search]}%' OR highlights ILIKE '%#{params[:search]}%'")
    end
    limit_page_numbers
    @location = ''
    if params[:sort].present? && params[:sort] == 'price'
      @deals = @deals.order(sort_price: :asc)
    else
      @deals = @deals.order(rating: :desc)
    end
    # for the recommended deals in the sidebar
    @recommended_deals = @deals.order('RANDOM()').limit(4) if @deals.count > 4
    # paginate deals
    @deals = @deals.paginate(page: params[:page], per_page: 20)
    @related_searches = %w[Teeth Car Paint Cheap Beauty Luxury Nails Massage Spa]
  end

  private

  def category_query
    if params[:category].present?
      return tidy_string(params[:category])
    else
      return ''
    end
  end
end
