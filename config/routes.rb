 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#index'

  resources :categories do
   resources :recipes
  end

  get '/:category_slug/:recipe_slug/', to: 'recipes#show', as: 'recipe'

  controller :public_pages do
    get '/calculator', action: 'calculator', as: 'public_page_calculator'
    get '/about', action: 'about', as: 'public_page_about'
  end

  get '/robots.txt' => 'home#robots'

  get '/ebook', to: 'ebook_signups#index'
  resources :ebook_signups
end
