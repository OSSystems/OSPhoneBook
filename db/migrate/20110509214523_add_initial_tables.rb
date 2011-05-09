class AddInitialTables < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name
      t.timestamps
    end

    create_table :contacts do |t|
      t.string :name
      t.text :comments
      t.references :company
      t.timestamps
    end

    create_table :phone_numbers do |t|
      t.string :number
      t.integer :phone_type
      t.references :contact
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name
      t.timestamps
    end

    create_table :contacts_tags do |t|
      t.references :contact, :tag
      t.timestamps
    end
  end

  def self.down
    drop_tables :contacts_tags, :tags, :phone_numbers, :contacts, :companies
  end
end
