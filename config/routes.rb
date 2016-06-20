Rails.application.routes.draw do
  resources :users
  resources :articles do
    collection do
      get 'typeahead'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
