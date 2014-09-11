Rails.application.routes.draw do

  devise_for :users

  resources :card_scans do
    collection do
      get 'driverslicense'
      get 'passport'
      get 'identitycard'
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
    end
  end

  resources :profiles do
    collection do
      get 'viewprofile'
    end
  end
  
  root 'card_scans#index'
  get 'sixt' => 'card_scans#index', as: :sixt

end
