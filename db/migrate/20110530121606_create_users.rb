class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :extension
      t.database_authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.timestamps
    end
    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true

    user = User.create!({:name => "Admin", :email => "admin@example.org"})
    user.attempt_set_password({:password => "admin", :password_confirmation => "admin"})
    user.confirm!

    puts "******************************************************\n" +
      "Users created! Use the following to log in the system:\n" +
      "login: admin@example.org\n" +
      "password: admin\n" +
      "******************************************************"
  end

  def self.down
    drop_table :users
  end
end
