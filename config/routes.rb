 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#index'

  resources :categories do
   resources :recipes
  end

  get '/:category_slug/:recipe_slug/', to: 'recipes#show', as: 'recipe'

  get '*public_page' => 'public_pages#show', as: 'public_pages'

  get '/robots.txt' => 'home#robots'

  get '/ebook', to: 'ebook_signups#index'
  resources :ebook_signups
end
