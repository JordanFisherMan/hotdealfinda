class ResultsController < ApplicationController
  def results
    fetch
    @search = params[:search] || ''
    @deals = @deals.where("title ILIKE '%#{params[:search]}%' OR highlights ILIKE '%#{params[:search]}%'")
  end
end
