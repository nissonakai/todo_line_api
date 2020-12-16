Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :todos
      post '/callback', to: 'linebot#callback'
    end
  end
end
