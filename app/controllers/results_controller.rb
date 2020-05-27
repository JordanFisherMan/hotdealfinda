# frozen_string_literal: true
require 'rest-client'
class ResultsController < ApplicationController
  include ApplicationHelper

  def results
    fetch
    countries_dropdown
    @gclid = gclid
    @search = {
      present: params[:search].present? && params[:search] != '',
      title: 'Search',
      query: params[:search] || ''
    }
    @category = {
      present: params[:category].present?,
      title: 'Category',
      query: category_query
    }
    @sort = {
      present: params[:sort].present?,
      title: 'Sort',
      query: params[:sort] || ''
    }
    @location = if params[:location].present?
                  params[:location]
                elsif !@deals.where(country_code: session[:country_code]).empty?
                  session[:country_code]
                else
                  'US'
                end

    query = []
    query.push("country_code LIKE '#{@location}'")
    if @search[:present]
      if @search[:query] == 'xbox one'
        query.push("(title ILIKE '%xbox one%' AND title ILIKE '%console%' AND title NOT ILIKE '%remote%' AND title NOT ILIKE '%box only%' AND title NOT ILIKE '%original box%')")
      elsif @search[:query] == 'xbox one games'
        query.push("(category LIKE 'video-games' AND title NOT ILIKE '%gift card%' AND title NOT ILIKE '%giftcard%')")
      elsif @search[:query] == 'xbox one accessories'
        query.push("(category LIKE 'xbox-one-accessories' AND title NOT ILIKE '%no accessories%' AND title NOT ILIKE '%console%' AND title NOT ILIKE '%Xbox One XBOX-ONE(XB1)%')")
      elsif @search[:query] == 'xbox one x'
        query.push("(title ILIKE '%xbox one x%' AND title ILIKE '%console%')")
      elsif @search[:query] == 'xbox one controller'
        query.push("(category LIKE 'xbox-one-controller')")
      elsif @search[:query] == 'xbox one strategy guides'
        query.push("(category LIKE 'xbox-one-strategy-guides' AND title ILIKE '%xbox one%')")
      elsif @search[:query] == 'xbox one elite controller'
        query.push("((title ILIKE '%#{@search[:query]}%' OR highlights ILIKE '%#{@search[:query]}%') AND title NOT ILIKE '%accessories%' AND title NOT ILIKE '%bumpers%' AND title NOT ILIKE '%kit%')")
      elsif @search[:present]
        query.push("(title ILIKE '%#{@search[:query]}%' OR highlights ILIKE '%#{@search[:query]}%')")
      end
    end
    if params[:category].present? && @category[:query] != 'all'
      query.push("category LIKE '#{params[:category]}'")
    end
    @results = @deals.where(query.join(' AND '))
    if @search[:present] && @search[:query] == 'xbox one games'
      @results = @results.order("random()")
    elsif params[:sort].present? && params[:sort] == 'price'
      @results = @results.order(sort_price: :asc)
    else
      @results = @results.order(rating: :desc)
    end
    limit_page_numbers
    # for the recommended deals in the sidebar
    @recommended_deals = if @results.count > 4
                           @results.order('RANDOM()').limit(4)
                         else
                           @deals.order('RANDOM()').limit(4)
    end
    # paginate deals
    @results = @results.paginate(page: params[:page], per_page: 20)
    if @search[:present] && xbox_related_search
      xbox_related_searches = ['xbox live', 'xbox one x', 'xbox one controller', 'xbox gift card', 'xbox one elite controller', 'xbox one accessories']
      xbox_related_searches.delete(@search[:query])
      @related_searches = xbox_related_searches
    else
      @related_searches = %w[Teeth Car Paint Cheap Beauty Luxury Nails Massage Spa]
    end

    @current_filters = []
    @current_filters.push(@search) if @search[:present]
    @current_filters.push(@category) if @category[:present]

    # target page title
    if @search[:present] && @search[:query] == 'xbox one'
      @title = 'Xbox One Deals'
    end
  end

  def get_live_price
  url = "https://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=JordanFi-HotDeals-PRD-58ec8fa73-6837b72f&siteid=0&version=967&ItemID=#{params[:id]}"
    begin
      response = RestClient.get(url)
    rescue RestClient::BadRequest => e
      log "Error: #{e}"
      return nil
    end
    json = JSON.parse(response.body)
    render json: json
  end

  def get_results
    
  end

  private

  def category_query
    if params[:category].present?
      tidy_string(params[:category])
    else
      ''
    end
  end

  def xbox_related_search
    @search[:query] == 'xbox one' ||
    @search[:query] == 'xbox one games' ||
    @search[:query] == 'xbox one accessories' ||
    @search[:query] == 'xbox one strategy guides' ||
    @search[:query] == 'xbox live' ||
    @search[:query] == 'xbox one x' ||
    @search[:query] == 'xbox one controller' ||
    @search[:query] == 'xbox gift card' ||
    @search[:query] == 'xbox one elite controller' ||
    @search[:query] == 'xbox one accessories'
  end
end
