class ApplicationController < ActionController::Base
  def index
    @deals = Deal.all.limit(10)
    @channels = [
      {
        title: 'all',
        link: ''
      },
      {
        title: 'local',
        link: ''
      },
      {
        title: 'goods',
        link: ''
      },
      {
        title: 'travel',
        link: ''
      }
    ]
  end

  def about; end

  def terms_and_conditions; end
end
