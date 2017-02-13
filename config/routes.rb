Rails.application.routes.draw do
  root 'pages#butter'
  get '/butter', to: 'pages#butter', as: 'butter'
  get '/coconut-oil', to: 'pages#coconut_oil', as: 'coconut_oil'
  get '/brownie', to: 'pages#brownie', as: 'brownie'
  get '/pizza', to: 'pages#pizza', as: 'pizza'
  get '/crackers', to: 'pages#crackers', as: 'crackers'
  get '/cookies', to: 'pages#cookies', as: 'cookies'
end
