 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#show'
  get '/:recipe_slug', to: 'recipes#show', as: 'recipe'
end
