class ResultsController < ApplicationController
  def results
    fetch
    @search = {
      present: params[:search].present?,
      title: 'Search',
      query: params[:search] || ''
    }

    @deals = @deals.where("title ILIKE '%#{params[:search]}%' OR highlights ILIKE '%#{params[:search]}%'")
  end
end
