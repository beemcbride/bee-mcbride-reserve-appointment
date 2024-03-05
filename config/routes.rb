Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # View, create, and confirm appointments
  get 'appointments', to: 'appointment#index'
  post 'appointments', to: 'appointment#create'
  put 'appointments/confirm', to: 'appointment#confirm'

  # View and create provider availability (appointment time slots)
  get 'availability', to: 'provider_availability#index'
  post 'availability', to: 'provider_availability#create'

  # View and create providers
  get 'providers', to: 'provider#index'
  post 'providers', to: 'provider#create'

  # View and create clients
  get 'clients', to: 'client#index'
  post 'clients', to: 'client#create'

  # Defines the root path route ("/")
  root "application#index"
end
