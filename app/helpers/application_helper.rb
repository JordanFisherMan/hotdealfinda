module ApplicationHelper
  def tidy_string(string)
    split = string.split('-')
    split.join(' ')
  end
end
