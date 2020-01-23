 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#index'

  resources :categories do
   resources :recipes
  end

  get '/:category_slug/:recipe_slug/', to: 'recipes#show', as: 'recipe'

  get '/contact', to: 'contact_messages#new', as: 'new_contact_message'
  post '/contact', to: 'contact_messages#create', as: 'create_contact_message'

  get '*public_page' => 'public_pages#show', as: 'public_pages'

  get '/robots.txt' => 'home#robots'

  get '/ebook', to: 'ebook_signups#index'
  resources :ebook_signups
end
