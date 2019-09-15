class ResultsController < ApplicationController
  def results
    fetch
    @search = {
      present: params[:search].present?,
      title: 'Search',
      query: params[:search] || ''
    }
    if params[:search].present? && params[:search] != ''
      @deals = @deals.where("title ILIKE '%#{params[:search]}%' OR highlights ILIKE '%#{params[:search]}%'")
    end
    limit_page_numbers
    @category = ''
    @location = ''
    if params[:sort].present? && params[:sort] == 'price'
      @deals = @deals.order(sort_price: :asc)
    else
      byebug
      @deals = @deals.order(rating: :asc)
    end
    @deals = @deals.paginate(page: params[:page], per_page: 20)
    byebug
  end
end
