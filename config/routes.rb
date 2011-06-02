OsPhoneBook::Application.routes.draw do
  resources :contacts, :except => :index do
    member do
      delete "tag_remove/:tag_id" => :tag_remove, :as => :tag_remove
    end
  end

  controller "contacts" do
    get "/company_search" => :company_search
    get "/tag_search" => :tag_search
    post "/set_tags" => :set_tags
  end

  controller "contact_search" do
    get "/search" => :search
  end
  root :to => "contact_search#index"

  get "/contacts/:id/contact_show.rjs" => "contacts#show_javascript", :as => ""

  controller "asterisk" do
    get "/dial/:id" => :dial, :as => :dial
    get "/callerid_lookup" => :lookup, :as => :callerid_lookup
  end

  controller "passwords" do
    get "/user/change_password" => :edit, :as => :change_password
    put "/user/change_password" => :update
  end

  as :user do
    put '/user/confirmation' => 'confirmations#update', :as => :update_user_confirmation
    get '/user/confirmation' => 'confirmations#show', :as => :show_user_confirmation
  end

  devise_for :users, :controllers => { :confirmations => "confirmations" }

  resources :users
end
