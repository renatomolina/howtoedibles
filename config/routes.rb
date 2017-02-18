Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'pages#show'
  get '/:recipe_slug', to: 'pages#show', as: 'recipe'
end
