class ApplicationController < ActionController::Base
  def index
    @deals = Deal.all.limit(10)
    @channels = [
      {
        title: 'all',
        link: root_path(channel: 'all')
      },
      {
        title: 'local',
        link: root_path(channel: 'local')
      },
      {
        title: 'goods',
        link: root_path(channel: 'goods')
      },
      {
        title: 'travel',
        link: root_path(channel: 'travel')
      }
    ]
    @channel = params[:channel].present? ? params[:channel] : 'all'
  end

  def about; end

  def terms_and_conditions; end
end
