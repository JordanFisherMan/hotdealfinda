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
    if @search[:present] && @search[:query] == 'xbox one'
      query.push("(title ILIKE '%xbox one%' AND title ILIKE '%console%' OR highlights ILIKE '%xbox one%')")
    elsif @search[:present]
      query.push("(title ILIKE '%#{@search[:query]}%' OR highlights ILIKE '%#{@search[:query]}%')")
    end
    if params[:category].present? && @category[:query] != 'all'
      query.push("category LIKE '#{params[:category]}'")
    end
    @results = @deals.where(query.join(' AND '))
    limit_page_numbers
    @results = if params[:sort].present? && params[:sort] == 'price'
                 @results.order(sort_price: :asc)
               else
                 @results.order(rating: :desc)
            end
    # for the recommended deals in the sidebar
    @recommended_deals = if @results.count > 4
                           @results.order('RANDOM()').limit(4)
                         else
                           @deals.order('RANDOM()').limit(4)
    end
    # paginate deals
    @results = @results.paginate(page: params[:page], per_page: 20)

    if @search[:present] && @search[:query] == 'xbox one'
      deal1 = Deal.new(
        image_url: "//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&MarketPlace=US&ASIN=B07XQXZXJC&ServiceVersion=20070822&ID=AsinImage&WS=1&Format=_SL250_&tag=hotdealsfinda-20",
        title: "Xbox One S 1TB All-Digital Edition Console (Disc-free Gaming)",
        price: "$172.90",
        url: "https://www.amazon.com/gp/product/B07XQXZXJC/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B07XQXZXJC&linkCode=as2&tag=hotdealsfinda-20&linkId=8ca5a50e726f765ddc2fc4e1f0be7850",
        rating: "true"
      )
      deal2 = Deal.new(
        image_url: "https://images-na.ssl-images-amazon.com/images/I/41uJnnEKMHL._SL250_.jpg",
        url: "https://www.amazon.com/gp/product/B07VFY91HM/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B07VFY91HM&linkCode=as2&tag=hotdealsfinda-20&linkId=76a59497285660e73b2268e0ebd9127f",
        title: "Xbox One S 1TB Console - NBA 2K20 Bundle",
        price: "$225.00",
        rating: "true"
      )
      deal3 = Deal.new(
        image_url: "//ws-na.amazon-adsystem.com/widgets/q?_encoding=UTF8&MarketPlace=US&ASIN=B07P19XP84&ServiceVersion=20070822&ID=AsinImage&WS=1&Format=_SL250_&tag=hotdealsfinda-20",
        url: "https://www.amazon.com/gp/product/B07P19XP84/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B07P19XP84&linkCode=as2&tag=hotdealsfinda-20&linkId=4c7fc47a07882a74f2b097ef4fa00b62",
        title: "Microsoft Xbox One S 1TB Console with Xbox One Wireless Controller - Robot White",
        price: "$207.00",
        rating: "true"
      )
      @results = @results.to_a.unshift(deal1, deal2, deal3)
      @related_searches = ['xbox live', 'xbox one x', 'xbox one controller', 'xbox live gold', 'crackdown 3', 'zoo tycoon', 'halo reach', 'xbox gift card', 'elite controller', 'skyrim']
    else
      @related_searches = %w[Teeth Car Paint Cheap Beauty Luxury Nails Massage Spa]
    end

    @current_filters = []
    @current_filters.push(@search) if @search[:present]
    @current_filters.push(@category) if @category[:present]

    # target page title
    if @search[:present] && @search[:query] == 'xbox one'
      @title = "Xbox One Deals"
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
