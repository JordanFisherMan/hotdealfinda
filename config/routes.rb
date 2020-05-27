Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'application#index'
  get 'results', to: 'results#results'
  get 'get_results', to: 'results#get_results'
  get 'about', to: 'info#about'
  get 'terms-and-conditions', to: 'info#terms_and_conditions', as: :terms_and_conditions
  get 'privacy', to: 'info#privacy'
  get 'contact', to: 'info#contact'
  get 'categories', to: 'application#categories'
  get 'get_live_price', to: 'results#get_live_price'
end
