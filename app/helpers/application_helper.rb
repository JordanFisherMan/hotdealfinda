module ApplicationHelper
  def tidy_string(string)
    split = string.split('-')
    split.join(' ')
  end

  def url_friendly(string)
    split = string.downcase.split(' ')
    split.join('-')
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  # takes a filter to avoid and sends the params for all of the rest
  def current_filters(new_filter = nil)
    filters = @current_filters.map{ |filter|
      unless filter[:title] == new_filter
        "&#{filter[:title].downcase}=#{filter[:query]}"
      end
    }
    filters.join
  end
end
