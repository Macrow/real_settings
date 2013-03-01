require 'rubygems'
require 'rspec'
require 'active_record'
require File.join(File.dirname(__FILE__), '..', 'lib', 'real_settings')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

class User < ActiveRecord::Base
  has_settings :defaults => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4', :page_count => 20 }
end

class Account < ActiveRecord::Base
  has_settings
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :key, :null => false
      t.text   :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :null => true
      t.timestamps
    end
    add_index :settings, [ :target_type, :target_id, :key ], :unique => true
    
    create_table :users do |t|
      t.string :name
    end
    
    create_table :accounts do |t|
      t.string :name
    end
  end
end