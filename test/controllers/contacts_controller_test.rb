require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContactsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "show" do
    contact = Contact.create!(default_hash(Contact))
    get :show, params: {id: contact.id}
    assert_response :success
  end

  test "show with contact without company" do
    contact = Contact.create!(default_hash(Contact))
    contact.company.destroy
    get :show, params: {id: contact.id}
    assert_response :success
  end

  test "show with invalid id" do
    get :show, params: {id: 99999}
    assert_response :not_found
  end

  test "show without sign in" do
    sign_out users(:admin)
    contact = Contact.create!(default_hash(Contact))
    get :show, params: {id: contact.id}
    assert_response :success
  end

  test "show with phone number and skype contact" do
    contact = Contact.create!(default_hash(Contact))
    PhoneNumber.create!(default_hash(PhoneNumber, contact_id: contact.id))
    SkypeContact.create!(default_hash(SkypeContact, contact_id: contact.id))
    get :show, params: {id: contact.id}
    assert_response :success
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "new with params" do
    get :new, params: {contact: {name: "John Doe"}}
    assert_response :success
  end

  test "new without sign in" do
    sign_out users(:admin)
    get :new
    assert_redirected_to new_user_session_path
  end

  test "create" do
    check_for_changes(Company => +1, Contact => +1) do
      post :create, params: {contact: default_hash(Contact)}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    contact.reload
    assert contact.tags.empty?
  end

  test "create with a phone number" do
    attr = default_hash(Contact)
    phone_attr = default_hash(PhoneNumber)
    phone_attr.delete(:contact_id)
    attr[:phone_numbers_attributes] = {'0' => phone_attr}
    Contact.delete_all
    check_for_changes(Contact => +1, PhoneNumber => +1) do
      post :create, params: {contact: attr}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert contact.tags.empty?
    assert_equal 1, contact.phone_numbers.count
    phone = contact.phone_numbers[0]
    assert_equal phone_attr[:number], phone.number
    assert_equal 1, phone.phone_type
  end

  test "create with a skype contact" do
    attr = default_hash(Contact)
    skype_attr = default_hash(SkypeContact)
    skype_attr.delete(:contact_id)
    attr[:skype_contacts_attributes] = {'0' => skype_attr}
    Contact.delete_all
    check_for_changes(Contact => +1, SkypeContact => +1) do
      post :create, params: {contact: attr}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert_nil contact.company
    assert contact.tags.empty?
    assert_equal 1, contact.skype_contacts.count
    skype = contact.skype_contacts[0]
    assert_equal skype_attr[:username], skype.username
  end

  test "create with a phone number and skype contact" do
    attr = default_hash(Contact)
    phone_attr = default_hash(PhoneNumber)
    phone_attr.delete(:contact_id)
    attr[:phone_numbers_attributes] = {'0' => phone_attr}
    skype_attr = default_hash(SkypeContact)
    skype_attr.delete(:contact_id)
    attr[:skype_contacts_attributes] = {'0' => skype_attr}
    Contact.delete_all
    check_for_changes(Contact => +1, PhoneNumber => +1, SkypeContact => +1) do
      post :create, params: {contact: attr}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert contact.tags.empty?
    assert_equal 1, contact.phone_numbers.count
    phone = contact.phone_numbers[0]
    assert_equal phone_attr[:number], phone.number
    assert_equal 1, phone.phone_type
    assert_equal 1, contact.skype_contacts.count
    skype = contact.skype_contacts[0]
    assert_equal skype_attr[:username], skype.username
  end

  test "create specifying new company" do
    hash = default_hash(Contact)
    hash.delete :company
    check_for_changes(Company => +1, Contact => +1) do
      post :create, params: {contact: hash, company_search_field: "A New Company"}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert_equal "A New Company", contact.company.name
  end

  test "create specifying existing company" do
    company = Company.create default_hash(Company, name: "Existing Company")
    hash = default_hash(Contact)
    hash.delete :company
    hash[:company_id] = company.id
    check_for_changes(Contact => +1) do
      post :create, params: {contact: hash, company_search_field: "Existing Company"}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    contact.reload
    assert_equal "Existing Company", contact.company.name
  end

  test "create without specifying company" do
    hash = default_hash(Contact)
    hash.delete :company
    check_for_changes(Contact => +1) do
      post :create, params: {contact: hash, company_search_field: ""}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert_nil contact.company
  end

  test "create specifying new tag" do
    Tag.delete_all
    hash = default_hash(Contact)
    hash.delete :company
    check_for_changes(Contact => +1, Tag => +1) do
      post :create, params: {contact: hash, tags: ["tag 1"]}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert_equal ["tag 1"], contact.tags.collect{|tag| tag.name}
  end

  test "create specifying existing tag" do
    Tag.delete_all
    Tag.create!(name: "tag 1")
    hash = default_hash(Contact)
    hash.delete :company
    check_for_changes(Contact => +1, Tag => +1) do
      post :create, params: {contact: hash, tags: ["tag 1", "tag 2"]}
    end
    assert_redirected_to root_path
    assert_equal "Contact created.", flash[:notice]
    contact = Contact.order(:created_at).last
    assert_equal ["tag 1", "tag 2"], contact.tags.collect{|tag| tag.name}.sort
  end

  test "create with invalid data" do
    hash = default_hash(Contact, name: nil)
    check_for_no_changes do
      post :create, params: {contact: hash}
    end
    assert_response :unprocessable_entity
  end

  test "create with invalid data specifying tags keep new tags" do
    Tag.delete_all
    check_for_changes(Tag => +2) do
      post :create, params: {contact: {}, tags: ["tag 1", "tag 2"]}
    end
    assert_response :unprocessable_entity
  end

  test "create without sign in" do
    sign_out users(:admin)
    hash = default_hash(Contact)
    company = Company.find hash[:company_id]
    check_for_no_changes do
      post :create, params: {contact: hash, company_search_field: company.name}
    end
    assert_redirected_to new_user_session_path
  end

  test "edit" do
    contact = Contact.create!(default_hash(Contact))
    get :edit, params: {id: contact.id}
    assert_response :success
  end

  test "edit with invalid id" do
    get :edit, params: {id: 99999}
    assert_response :not_found
  end

  test "edit without sign in" do
    sign_out users(:admin)
    contact = Contact.create!(default_hash(Contact))
    get :edit, params: {id: contact.id}
    assert_redirected_to new_user_session_path
  end

  test "update" do
    contact = Contact.create!(default_hash(Contact))
    assert_not_equal "Apolonium", contact.name
    check_for_no_changes do
      put :update, params: {id: contact.id, contact: {name: "Apolonium"}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    assert contact.tags.empty?
  end

  test "update adding a phone number" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal 0, contact.phone_numbers.count
    phone_attr = default_hash(PhoneNumber)
    phone_attr.delete(:contact_id)
    check_for_changes(PhoneNumber => +1) do
      put :update, params: {id: contact.id, contact: {name: "Apolonium", phone_numbers_attributes: {'0' => phone_attr}}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    phone = contact.phone_numbers[0]
    assert_equal phone_attr[:number], phone.number
    assert_equal 1, phone.phone_type
  end

  test "update removing a phone number" do
    contact = Contact.create!(default_hash(Contact))
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, contact_id: contact.id))
    contact.reload
    assert_equal 1, contact.phone_numbers.count
    phone_attr = phone_number.attributes
    phone_attr.delete(:contact_id)
    phone_attr[:_destroy] = '1'
    check_for_changes(PhoneNumber => -1) do
      put :update, params: {id: contact.id, contact: {name: "Apolonium", phone_numbers_attributes: {'0' => phone_attr}}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    assert contact.tags.empty?
    assert_equal 0, contact.phone_numbers.count
  end

  test "update adding a skype contact" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal 0, contact.skype_contacts.count
    skype_attr = default_hash(SkypeContact)
    skype_attr.delete(:contact_id)
    check_for_changes(SkypeContact => +1) do
      put :update, params: {id: contact.id, contact: {name: "Apolonium", skype_contacts_attributes: {'0' => skype_attr}}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    assert contact.tags.empty?
    assert_equal 1, contact.skype_contacts.count
    skype = contact.skype_contacts[0]
    assert_equal skype_attr[:username], skype.username
  end

  test "update removing a skype contact" do
    contact = Contact.create!(default_hash(Contact))
    skype_contact = SkypeContact.create!(default_hash(SkypeContact, contact_id: contact.id))
    contact.reload
    assert_equal 1, contact.skype_contacts.count
    skype_attr = skype_contact.attributes
    skype_attr.delete(:contact_id)
    skype_attr[:_destroy] = '1'
    check_for_changes(SkypeContact => -1) do
      put :update, params: {id: contact.id, contact: {name: "Apolonium", skype_contacts_attributes: {'0' => skype_attr}}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    assert contact.tags.empty?
    assert_equal 0, contact.skype_contacts.count
  end

  test "update adding a phone number and a skype contact" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal 0, contact.phone_numbers.count
    assert_equal 0, contact.skype_contacts.count
    phone_attr = default_hash(PhoneNumber)
    phone_attr.delete(:contact_id)
    skype_attr = default_hash(SkypeContact)
    skype_attr.delete(:contact_id)
    check_for_changes(PhoneNumber => +1, SkypeContact => +1) do
      put :update, params: {id: contact.id, contact: {name: "Apolonium", phone_numbers_attributes: {'0' => phone_attr}, skype_contacts_attributes: {'0' => skype_attr}}, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    contact.reload
    assert_equal "Apolonium", contact.name
    assert contact.tags.empty?
    assert_equal 1, contact.phone_numbers.count
    phone = contact.phone_numbers[0]
    assert_equal phone_attr[:number], phone.number
    assert_equal 1, phone.phone_type
    assert_equal 1, contact.skype_contacts.count
    skype = contact.skype_contacts[0]
    assert_equal skype_attr[:username], skype.username
  end

  test "update with invalid id" do
    check_for_no_changes do
      put :update, params: {id: 99999, contact: {name: "Apolonium"}}
    end
    assert_response :not_found
  end

  test "update with invalid data" do
    contact = Contact.create!(default_hash(Contact))
    previous_name = contact.name
    check_for_no_changes do
      put :update, params: {id: contact.id, contact: {name: nil}}
    end
    assert_response :unprocessable_entity
    contact.reload
    assert_equal previous_name, contact.name
  end

  test "update specifying new company, removing old" do
    contact = Contact.create!(default_hash(Contact))
    hash = contact.attributes
    check_for_no_changes do
      put :update, params: {id: contact.id, contact: hash, company_search_field: "A New Company"}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert_equal "A New Company", contact.company.name
  end

  test "update specifying existing company" do
    contact = Contact.create!(default_hash(Contact))
    Company.delete_all
    company = Company.create! default_hash(Company, name: "Existing Company")
    hash = contact.attributes
    hash.delete :company
    hash[:company_id] = company.id
    assert_not_equal company, contact.company
    check_for_no_changes do
      put :update, params: {id: contact.id, contact: hash, company_search_field: "Existing Company"}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert_equal company, contact.company
  end

  test "update without specifying company" do
    contact = Contact.create!(default_hash Contact)
    Company.delete_all
    company = Company.create!(default_hash(Company, name: "Bankrupt Company"))
    contact.company = company
    contact.save!
    hash = contact.attributes
    hash.delete :company
    assert_equal company, contact.company
    check_for_changes(Company => -1) do
      put :update, params: {id: contact.id, contact: hash, company_search_field: ""}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert_nil Company.find_by_name "Bankrupt Company"
  end

  test "update specifying new tag" do
    contact = Contact.create!(default_hash(Contact))
    hash = contact.attributes
    Tag.delete_all
    check_for_changes(Tag => +1) do
      put :update, params: {id: contact.id, contact: hash, tags: ["tag 1"], company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert_equal ["tag 1"], contact.tags.collect{|tag| tag.name}
  end

  test "update specifying existing tag" do
    contact = Contact.create!(default_hash(Contact))
    hash = contact.attributes
    Tag.create!(name: "tag 1")
    check_for_changes(Tag => +1) do
      put :update, params: {id: contact.id, contact: hash, tags: ["tag 1", "tag 2"], company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert_equal ["tag 1", "tag 2"], contact.tags.collect{|tag| tag.name}
  end

  test "update clearing tags" do
    tag1 = Tag.create!(name: "tag 1")
    tag2 = Tag.create!(name: "tag 2")
    contact = Contact.create!(default_hash(Contact))
    hash = contact.attributes
    contact.tags = [tag1, tag2]
    contact.save!
    check_for_changes(Tag => -2) do
      put :update, params: {id: contact.id, contact: hash, company_search_field: contact.company.name}
    end
    assert_redirected_to root_path
    assert_equal "Contact updated.", flash[:notice]
    contact.reload
    assert contact.tags.empty?
    # delete tags if there are not any contacts associated with them:
    assert_nil Tag.find_by_name "tag 1"
    assert_nil Tag.find_by_name "tag 2"
  end

  test "update with invalid data specifying tags keep new tags" do
    contact = Contact.create!(default_hash(Contact))
    Tag.delete_all
    check_for_changes(Tag => +2) do
      post :create, params: {id: contact.id, contact: {}, tags: ["tag 1", "tag 2"]}
    end
    assert_response :unprocessable_entity
    contact.reload
    assert contact.tags.empty?
  end

  test "update without sign in" do
    sign_out users(:admin)
    contact = Contact.create!(default_hash(Contact))
    check_for_no_changes do
      put :update, params: {id: contact.id, contact: {name: "Apolonium"}}
    end
    assert_redirected_to new_user_session_path
  end

  test "company search with a simple term" do
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, company: company))
    get :company_search, params: {term: "Placebo"}
    assert_response :success
    expected = [
      {"value" => company.name, "label" => company.name},
      {"label" => "Create new company for 'Placebo'", "value" => "Placebo"}]
    assert_equal expected, JSON::load(@response.body)
    assert_equal 'application/json', @response.content_type
  end

  test "company search without sign in" do
    sign_out users(:admin)
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, company: company))
    get :company_search, params: {query: "Placebo"}
    assert_redirected_to new_user_session_path
  end

  test "tag search with a simple term" do
    tag = Tag.create!(default_hash(Tag))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    get :tag_search, params: {term: "ab"}
    assert_response :success
    expected = [
      {"value" => tag.name, "label" => tag.name},
      {"label" => "Create new tag named 'ab'", "value" => "ab"}]
    assert_equal expected, JSON::load(@response.body)
    assert_equal 'application/json', @response.content_type
  end

  test "tag search without sign in" do
    sign_out users(:admin)
    tag = Tag.create!(default_hash(Tag))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    get :tag_search, params: {query: "ab"}
    assert_redirected_to new_user_session_path
  end

  test "set new tag" do
    check_for_changes(Tag => +1) do
      post :set_tags, params: {add_tag: "abc", tags: []}
    end
    assert_response :success
    assert_equal ["abc"], Tag.all.collect{|t| t.name}
  end

  test "try to set blank tag" do
    post :set_tags, params: {add_tag: ""}
    assert_response :success
    assert Tag.all.empty?
  end

  test "set new tag with preexisting tags" do
    ["abc", "def"].each{|name| Tag.create!(name: name)}
    check_for_changes(Tag => +1) do
      post :set_tags, params: {add_tag: "ghi", tags: ["abc", "def"]}
    end
    assert_response :success
    assert_equal ["abc", "def", "ghi"], Tag.order(:name).all.collect{|t| t.name}
  end

  test "try to set same tag" do
    Tag.create!(name: "abc")
    check_for_no_changes do
      post :set_tags, params: {add_tag: "abc", tags: ["abc"]}
    end
    assert_response :success
    assert_equal ["abc"], Tag.all.collect{|t| t.name}
  end

  test "set tags without sign in" do
    sign_out users(:admin)
    post :set_tags, params: {add_tag: "abc", tags: []}
    assert_redirected_to new_user_session_path
    assert Tag.all.empty?
  end

  test "show route" do
    assert_routing(
      {method: :get, path: '/contacts/1'},
      {controller: 'contacts', action: 'show', id: "1"}
    )
  end

  test "new route" do
    assert_routing(
      {method: :get, path: '/contacts/new'},
      {controller: 'contacts', action: 'new'}
    )
  end

  test "create route" do
    assert_routing(
      {method: :post, path: '/contacts'},
      {controller: 'contacts', action: 'create'}
    )
  end

  test "edit route" do
    assert_routing(
      {method: :get, path: '/contacts/1/edit'},
      {controller: 'contacts', action: 'edit', id: "1"}
    )
  end

  test "update route" do
    assert_routing(
      {method: :put, path: '/contacts/1'},
      {controller: 'contacts', action: 'update', id: "1"}
    )
  end

  test "company search route" do
    assert_routing(
      {method: :get, path: '/company_search'},
      {controller: 'contacts', action: 'company_search'}
    )
  end

  test "tag search route" do
    assert_routing(
      {method: :get, path: '/tag_search'},
      {controller: 'contacts', action: 'tag_search'}
    )
  end

  private
  NO_CHANGE_CLASSES = {Company => 0,
                       Contact => 0,
                       PhoneNumber => 0,
                       SkypeContact => 0,
                       Tag => 0}.freeze

  def check_for_changes(changes)
    raise ArgumentError.new("Missing block") unless block_given?
    previous_values = {}
    NO_CHANGE_CLASSES.dup.merge(changes).each do |klass, difference|
      expected = klass.count + difference
      previous_values[klass] = [expected]
    end

    yield

    errors = {}
    previous_values.each do |klass, values|
      expected, _ = values
      actual = klass.count
      errors[klass] = {expected: expected, got: actual} if actual != expected
    end

    unless errors.empty?
      errors_messages = errors.collect do |klass, data|
        "  #{klass.name} - Expected: #{data[:expected]}, got: #{data[:got]}"
      end.sort
      fail "Failed model changes expectations!\n" + errors_messages.join("\n")
    end
    return true
  end

  def check_for_no_changes(&block)
    raise ArgumentError.new("Missing block") unless block_given?
    check_for_changes({}, &block)
  end
end
