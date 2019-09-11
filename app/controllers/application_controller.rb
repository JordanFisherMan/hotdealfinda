class ApplicationController < ActionController::Base
  def index
    fetch
    @category = @categories.find_by(slug: 'all')
    if params[:category].present?
      record = @categories.find_by(slug: params[:category])
      if record.present? && record.slug != 'all'
        @category = record
      end
    end
    unless @category.slug == 'all'
      @deals = @deals.where("category LIKE '#{@category.slug}'")
    end
    @deals = @deals.paginate(page: params[:page], per_page: 20).order("RANDOM()")
    # move 'all' category to the front of the array
    @categories = @categories.to_a
    all = @categories.detect{|c| c.slug == 'all' }
    @categories.delete(all)
    @categories.unshift(all)
    # show deals in random order
    @deals.shuffle
    # keep the visible page numbers to a limit so they don't overlap
    # on smaller screens
    WillPaginate::ViewHelpers.pagination_options[:inner_window] = 0
    WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0
  end

  def about; end

  def terms_and_conditions; end

  def fetch
    @categories = Category.all
    @deals = Deal.all
  end
end
