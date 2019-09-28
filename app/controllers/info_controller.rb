# frozen_string_literal: true

class InfoController < ApplicationController
  def about
    fetch
    countries_dropdown
  end

  def terms_and_conditions; end

  def privacy; end

  def contact
    fetch
    countries_dropdown
  end
end
