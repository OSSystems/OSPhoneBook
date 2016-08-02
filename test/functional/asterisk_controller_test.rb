require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../asterisk_mockup_server')
require 'asterisk_monitor'
require 'asterisk_monitor_config'

class AsteriskControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "dial" do
    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server
    server = start_asterisk_mock_server "foo", "bar"

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id, :dial_type => "phone"
    assert_redirected_to root_path
    assert_equal "Your call is now being completed.", flash[:notice]
    assert_equal "05312345678", server.last_dialed_to
    assert_equal "SIP/0001", server.last_dialed_from
  end

  test "dial with XmlHttpRequest" do
    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server
    server = start_asterisk_mock_server "foo", "bar"

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    xhr :get, :dial, :id => phone_number.id, :dial_type => "phone"
    assert_response :success
    assert_equal "Your call is now being completed.", @response.body
    assert_equal "05312345678", server.last_dialed_to
    assert_equal "SIP/0001", server.last_dialed_from
  end

  test "dial to inexistend phone number" do
    get :dial, :id => 9999, :dial_type => "phone"
    assert_response :not_found
  end

  test "dial without extension to sign in user" do
    users(:admin).extension = nil
    users(:admin).save!
    users(:admin).reload
    assert_nil users(:admin).extension

    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server
    start_asterisk_mock_server "foo", "bar"

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id, :dial_type => "phone"
    assert_redirected_to root_path
    assert_equal "You can't dial because you do not have an extension set to your user account.", flash[:notice]
  end

  test "dial skype user" do
    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server
    server = start_asterisk_mock_server "foo", "bar"

    skype_contact = SkypeContact.create!(default_hash SkypeContact, :username => "test_user")
    assert skype_contact.dial("0001")
    get :dial, :id => skype_contact.id, :dial_type => "skype"
    assert_redirected_to root_path
    assert_equal "Your call is now being completed.", flash[:notice]
    assert_equal "Skype/test_user", server.last_dialed_to
    assert_equal "SIP/0001", server.last_dialed_from
  end

  test "dial without sign in" do
    sign_out users(:admin)
    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server
    start_asterisk_mock_server "foo", "bar"

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id, :dial_type => "phone"
    assert_redirected_to new_user_session_path
    assert_nil assigns(:phone_number)
  end

  test "lookup number" do
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "lookup number with company" do
    contact = Contact.new(:name => "Jane Doe")
    contact.company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe - ULTRA Corp.", @response.body
  end

  test "lookup number with unknown number" do
    PhoneNumber.delete_all
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "lookup number with more than one contact, same company returns company" do
    contact1 = Contact.new(:name => "Jane Doe")
    company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    contact1.company = company
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    contact2.company = company
    contact2.phone_numbers = [PhoneNumber.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "ULTRA Corp.", @response.body
  end

  test "lookup number with more than one contact, no companies returns error" do
    contact1 = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    contact2.phone_numbers = [PhoneNumber.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "ERROR: duplicated number", @response.body
  end

  test "lookup number with more than one contact, different company returns error" do
    contact1 = Contact.new(:name => "Jane Doe")
    contact1.company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    contact2.company = Company.create!(default_hash Company, :name => "MEGA Corp.")
    contact2.phone_numbers = [PhoneNumber.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "ERROR: duplicated number", @response.body
  end

  test "lookup skype contact" do
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(SkypeContact, :username => "jane.doe")
    hash.delete :contact
    contact.skype_contacts = [SkypeContact.new(hash)]
    contact.save!
    get :lookup, :phone_number => "jane.doe"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "lookup same number and skype with more than one contact returns phone number contact" do
    contact1 = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    hash = default_hash(SkypeContact, :username => "skype87654321")
    hash.delete :contact
    contact2.skype_contacts = [SkypeContact.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "skype87654321"
    assert_response :success
    assert_equal "ERROR: duplicated number", @response.body
  end

  test "lookup number without number" do
    PhoneNumber.delete_all
    get :lookup
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "lookup number without sign in" do
    sign_out users(:admin)
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "dial route" do
    assert_routing(
      {:method => :get, :path => '/dial/phone/1'},
      {:controller => 'asterisk', :action => 'dial', :dial_type => "phone", :id => "1"}
    )
    assert_routing(
      {:method => :get, :path => '/dial/skype/1'},
      {:controller => 'asterisk', :action => 'dial', :dial_type => "skype", :id => "1"}
    )
  end

  test "call id lookup route" do
    assert_routing(
      {:method => :get, :path => '/callerid_lookup'},
      {:controller => 'asterisk', :action => 'lookup'}
    )
  end
end
