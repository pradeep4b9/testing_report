Rails.application.routes.draw do

  # devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations", :confirmations => "confirmations"}

  resources :users do
    collection do
      get 'email_confirmation'
    end
  end

  resources :card_scans do
    collection do
      get 'driverslicense'
      get 'passport'
      get 'identitycard'
      get 'identity_status'
    end
  end

  resources :voices do
    collection do
      get 'register'
      post 'record'
      get 'register_status'
      get 'login_status'
      get 'signin'
    end
  end  

  resources :photos do
    collection do
      get 'camera'
      post 'canvas_capture'
      get 'facedetection'
      get 'verify'
      post 'verify_status'
    end
  end

  resources :mobile_numbers do
    collection do
      get 'register'
      post 'submit_register'
      get 'verify'
      post 'submit_verify'
    end
  end 

  resources :profiles

  get 'country_code' => 'home#country_code', as: :country_code
  
  root 'card_scans#index'

  get 'sixt' => 'card_scans#index', as: :sixt

end
