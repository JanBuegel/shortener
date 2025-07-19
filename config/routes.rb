# config/routes.rb
Rails.application.routes.draw do
  get "/cli", to: "cli#show"
  get "/links", to: "links#index"
  post "/links", to: "links#create"
  get "/:short_token", to: "links#show"
end
