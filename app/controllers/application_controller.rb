class ApplicationController < ActionController::Base
  def index
    @categories = Category.all
    @deals = Deal.all
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

  end

  def about; end

  def terms_and_conditions; end
end
