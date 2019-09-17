module ApplicationHelper
  def tidy_string(string)
    split = string.split('-')
    split.join(' ')
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end
end
