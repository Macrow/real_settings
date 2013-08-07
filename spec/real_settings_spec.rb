require File.dirname(__FILE__) + '/spec_helper'

describe "RealSettings" do
  setup_db

  before(:each) do
    @app_name = "real_settings"
    @app_url = "http://github.real_settings.com"
    @app_online_at = Time.now
    @paginate_count = 10
    @app_open = true
    Settings.file_config do |settings|
      settings.app_name = @app_name
      settings.app_url = @app_url
      settings.app_online_at = @app_online_at
    end
    Settings.db_config_default do |settings|
      settings.paginate_count = @paginate_count
      settings.app_open = @app_open
    end
    @user1 = User.create!(:name => 'admin1')
    @user2 = User.create!(:name => 'admin2')
  end
  
  it "save value and get right value type" do
    at = Time.now
    Settings.a_array = [1,2,3,4,5]
    Settings.a_string = 'abc'
    Settings.a_time = at
    Settings.a_number = 123456
    Settings.a_float = 123.456
    Settings.a_bool_true = true
    Settings.a_bool_false = false
    
    Settings.save!
    Settings.reload!
      
    Settings.a_array.should == [1,2,3,4,5]
    Settings.a_string.should == 'abc'
    Settings.a_time.should.eql? at
    Settings.a_number.should == 123456
    Settings.a_float.should == 123.456
    Settings.a_bool_true.should == true
    Settings.a_bool_false.should == false
  end
  
  it "db_config_default load for default only" do
    Settings.save!
    Settings.reload!
    
    Settings.paginate_count.should == @paginate_count
    Settings.app_open.should == @app_open
    
    Settings.db_config_default do |settings|
      settings.paginate_count = 50
      settings.app_open = false
    end
    
    Settings.save!
    Settings.reload!
    
    Settings.paginate_count.should == @paginate_count
    Settings.app_open.should == @app_open
  end
  
  it "load default settings from config file" do
    Settings.app_name.should == @app_name
    Settings.app_url.should == @app_url
    Settings.app_online_at.should == @app_online_at
    Settings.paginate_count.should == @paginate_count
    Settings.app_open.should == @app_open
  end
  
  it "load settings priority is file > database > temp" do
    Settings.app_name = 'name from database'
    Settings.app_url = 'url from database'
    Settings.reload!
    Settings.app_name.should == @app_name
    Settings.app_url.should == @app_url
    
    Settings.app_name = 'new name'
    Settings.app_name.should == 'new name'
    Settings.reload!
    Settings.app_name.should == @app_name
  end
  
  it "load db default config" do
    Settings.paginate_count.should == @paginate_count
    Settings.app_open.should == @app_open
    Settings.reload!
    Settings.paginate_count.should == @paginate_count
    Settings.app_open.should.eql? @app_open
    Settings.paginate_count = 30
    new_open_time = Time.now
    Settings.app_open = new_open_time
    Settings.paginate_count.should == 30
    Settings.app_open.should == new_open_time
    Settings.save!
    Settings.paginate_count.should == 30
    Settings.app_open.should == new_open_time    
  end
  
  it "load default settings from database" do
    Settings.another_name = 'name from database'
    Settings.another_url = 'url from database'    
    Settings.save!
    Settings.reload!
    Settings.another_name.should == 'name from database'
    Settings.another_url.should == 'url from database'
  end
  
  it "reload feature" do
    Settings.new_name.should == nil
    Settings.new_name = 'new name'
    Settings.new_name.should == 'new name'
    Settings.reload!
    Settings.new_name.should == nil    
  end
  
  it "save settings into database" do
    Settings.new_name.should == nil
    Settings.new_name = 'new name'
    Settings.save!
    Settings.new_name.should == 'new name'
    Settings.reload!
    Settings.new_name.should == 'new name'
    
    Settings.create(:key => 'another_name', :value => 'name from database')
    Settings.another_name = 'new name'
    Settings.save!
    Settings.another_name.should == 'new name'
  end
  
  it "update settings from hash" do
    hash = Settings.to_hash
    hash[:new_feature_from_update_settings] = 'new_feature_from_update_settings'
    Settings.new_feature_from_update_settings.should == nil
    Settings.update_settings(hash)
    Settings.new_feature_from_update_settings.should == 'new_feature_from_update_settings'
    Settings.reload!
    Settings.new_feature_from_update_settings.should == 'new_feature_from_update_settings'
  end
  
  it "settings in config/initializers/real_settings.rb can't store in database" do
    Settings.app_name = 'new name'
    Settings.app_name.should == 'new name'
    Settings.save!
    Settings.app_name.should == @app_name
    Settings.reload!
    Settings.app_name.should == @app_name
  end
  
  it "has_settings without default values" do
    @account1 = Account.create!(:name => 'account1')
    @account1.settings.to_hash.should == {}
  end
  
  it "user has settings different with global settings" do
    @user1.settings.editor = 'textmate'
    @user1.settings.editor.should == 'textmate'
    @user1.settings.reload!
    @user1.settings.editor.should == nil
    @user1.settings.editor = 'textmate'
    @user1.save!
    @user1.settings.reload!
    @user1.settings.editor.should == 'textmate'
    
    Settings.editor.should == nil
  end
  
  it "user has same settings with global settings" do
    @user1.settings.app_name.should == nil
    @user1.settings.app_name = 'app name for user'
    @user1.save!
    @user1.settings.app_name.should == 'app name for user'
    Settings.app_name.should == @app_name
  end
  
  it "diferent users have same settings" do
    @user1.settings.editor = 'textmate'
    @user2.settings.editor = 'vim'
    @user1.settings.editor.should == 'textmate'
    @user2.settings.editor.should == 'vim'
    @user1.settings.reload!
    @user2.settings.reload!
    @user1.settings.editor.should == nil
    @user2.settings.editor.should == nil
    
    @user1.settings.editor = 'textmate'
    @user2.settings.editor = 'vim'
    @user1.save!
    @user2.save!
    @user1.settings.editor.should == 'textmate'
    @user2.settings.editor.should == 'vim'
  end
  
  it "diferent users have different settings" do
    @user1.settings.editor = 'textmate'    
    @user2.settings.editor.should == nil
    @user1.save!
    @user2.settings.editor.should == nil
  end
  
  it "user has default settings" do
    # has_settings :defaults => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4', :page_count => 20 }
    @user1.settings.to_hash[:notebook].should == 'Macbook Pro'
    @user1.settings.to_hash[:mobile].should == 'iPhone 4'    
    @user1.settings.to_hash[:page_count].should == 20
    @user1.settings.notebook.should == 'Macbook Pro'
    @user1.settings.mobile.should == 'iPhone 4'
    @user1.settings.page_count.should == 20
    
    @user1.settings.notebook = 'Macbook Air'
    @user1.settings.mobile = 'iPhone 4S'
    @user1.settings.page_count = 10
    @user1.settings.notebook.should == 'Macbook Air'
    @user1.settings.mobile.should == 'iPhone 4S'    
    @user1.settings.page_count.should == 10 
    @user1.settings.reload!
    @user1.settings.notebook.should == 'Macbook Pro'
    @user1.settings.mobile.should == 'iPhone 4'
    @user1.settings.page_count.should == 20

    @user1.settings.notebook = 'Macbook Air'
    @user1.settings.mobile = 'iPhone 4S'
    @user1.settings.page_count = 10
    @user1.save!
    @user1.settings.notebook.should == 'Macbook Air'
    @user1.settings.mobile.should == 'iPhone 4S'
    @user1.settings.page_count.should == 10
    @user1.settings.reload!
    @user1.settings.notebook.should == 'Macbook Air'
    @user1.settings.mobile.should == 'iPhone 4S'
    @user1.settings.page_count.should == 10
    
    @user2.settings.notebook.should == 'Macbook Pro'
    @user2.settings.mobile.should == 'iPhone 4'
    @user2.settings.page_count.should == 20
  end
  
  it "be sure destroy settings after destroy user" do
    @user1.settings.new_feature = "new setting for user"
    @user1.save!
    @user1.destroy
    Settings.where(:key => 'new_feature').should be_empty
  end
end