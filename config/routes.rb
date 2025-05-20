# config/routes.rb
Rails.application.routes.draw do
  post "/links", to: "links#create"
  get "/:short_token", to: "links#show"
end
