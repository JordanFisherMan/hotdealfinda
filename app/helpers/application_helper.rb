module ApplicationHelper
  def tidy_string(string)
    split = string.split('-')
    split.join(' ')
  end

  def asset_exists?(path)
    if Rails.env.production?
      Rails.application.assets_manifest.find_sources(path) != nil
    else
      Rails.application.assets.find_asset(path) != nil
    end
  end
end
