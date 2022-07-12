Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン機能
  get     '/login', to: 'sessions#new'
  post    '/login', to: 'sessions#create'
  delete  '/logout',  to: 'sessions#destroy'
  
  resources :bases

  resources :users do
      member do
        get 'edit_basic_info'
        patch 'update_basic_info'
        get 'attendances/edit_attendance_change_request'
        patch 'attendances/update_attendance_change_request'
        get 'attendances/edit_attendance_change_notice'
        patch 'attendances/update_attendance_change_notice'        
        get 'attendances/edit_overwork_request'
        patch 'attendances/update_overwork_request'
        get 'attendances/edit_overwork_notice'
        patch 'attendances/update_overwork_notice'
        get 'attendances/index_attendance_log'
      end
      collection do
        get 'go_work'
        post :import
      end
      resources :attendances, only: :update
    end
  end