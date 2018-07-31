 Rails.application.routes.draw do
  resources :categories
  ActiveAdmin.routes(self)
  mount Ckeditor::Engine => '/ckeditor'

  root 'recipes#index'

  resources :categories do
    resources :recipes, path: '', only: :show
  end
end
