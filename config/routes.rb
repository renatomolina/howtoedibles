 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#index'

  resources :categories do
   resources :recipes
  end
 
  get '/:category_slug/:recipe_slug/', to: 'recipes#show', as: 'recipe'
end
