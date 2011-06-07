class CreateSkypeContacts < ActiveRecord::Migration
  def self.up
    create_table :skype_contacts do |t|
      t.string :username
      t.references :contact
      t.timestamps
    end
    add_index :skype_contacts, :username, :unique => true
  end

  def self.down
    drop_table :skype_contacts
  end
end
