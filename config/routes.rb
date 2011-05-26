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
    get "/" => :index, :as => :root
  end

  get "/javascripts/:id/contact_show.js" => "contacts#show_javascript", :as => ""

  controller "asterisk_dial" do
    get "/dial/:id" => :dial, :as => :dial
  end
end
