Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Pages
  root "pages#entry"
  get "entry", to: "pages#entry", as: :entry_page
  post "entry", to: "pages#create_session"
  get "chat", to: "pages#chat", as: :chat_page
  post "chat/generate_response", to: "pages#generate_response", as: :generate_response
  post "chat/send_message", to: "pages#send_message", as: :send_message
  post "chat/diagnose", to: "pages#submit_diagnosis", as: :submit_diagnosis
  get "grading", to: "pages#grading", as: :grading_page
  post "grading/back_to_chat", to: "pages#back_to_chat", as: :back_to_chat
end
