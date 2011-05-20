OsPhoneBook::Application.routes.draw do
  resources :contacts, :except => :index
  get "/company_search" => :company_search, :controller => "contacts"

  controller "contact_search" do
    get "/search" => :search
    get "/" => :index, :as => :root
  end

  controller "asterisk_dial" do
    get "/dial/:id" => :dial, :as => :dial
  end
end
