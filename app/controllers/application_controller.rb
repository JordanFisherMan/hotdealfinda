# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def index
    fetch
    countries_dropdown
    session[:country] ||= Geocoder.search(request.remote_ip)
    @location = if params[:location].present?
                  params[:location]
                elsif !@deals.where(country_code: session[:country_code]).empty?
                  session[:country_code]
                else
                  'US'
                end
    if params[:category].present?
      record = @categories.find_by(slug: params[:category])
      @category = record if record.present?
      @deals = @deals.where("category LIKE '#{@category.slug}'")
    end
    @deals = @deals.paginate(page: params[:page], per_page: 20).order('RANDOM()')
    # separate categories for tabs and put 'all' at the front
    @category_tabs = @categories
    @category_tabs = @category_tabs.to_a
    all = Category.new(slug: 'all')
    @category_tabs.unshift(all)
    # show deals in random order
    @deals.shuffle
    limit_page_numbers
  end

  def about; end

  def terms_and_conditions; end

  def fetch
    @categories = Category.all
    @deals = Deal.all
  end

  # keep the visible page numbers to a limit so they don't overlap
  # on smaller screens
  def limit_page_numbers
    WillPaginate::ViewHelpers.pagination_options[:inner_window] = 0
    WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0
  end

  private

  def countries_dropdown
    @countries_dropdown = @deals.map do |d|
      [d.country_code, d.country_code]
    end
    @countries_dropdown.uniq!
  end
end
