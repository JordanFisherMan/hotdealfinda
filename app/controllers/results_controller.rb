# frozen_string_literal: true

class ResultsController < ApplicationController
  include ApplicationHelper

  def results
    fetch
    countries_dropdown
    affiliate_id
    gclid
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
        query.push("(title ILIKE '%xbox one%' AND title ILIKE '%console%' OR highlights ILIKE '%xbox one%')")
      elsif @search[:query] == 'xbox one games'
        query.push("(category LIKE 'video-games' AND title NOT ILIKE '%gift card%' AND title NOT ILIKE '%giftcard%')")
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
    if @search[:present] && @search[:query] == 'xbox one'
      @related_searches = ['xbox live', 'xbox one x', 'xbox one controller', 'xbox live gold', 'crackdown 3', 'zoo tycoon', 'halo reach', 'xbox gift card', 'elite controller', 'skyrim']
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

  private

  def category_query
    if params[:category].present?
      tidy_string(params[:category])
    else
      ''
    end
  end
end
