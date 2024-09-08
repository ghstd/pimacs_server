Rails.application.routes.draw do
  root "websocket#index"
  mount ActionCable.server => '/cable'
end
