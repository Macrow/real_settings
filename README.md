# RealSettings

RealSettings is a real settings tool for Rails3.

RealSetting load default settings from config file, and store settings in memory.

RealSetting can store settings in database.

RealSetting can store different settings for your model(activerecord model only).


## Installation

Add this line to your application's Gemfile:

    gem 'real_settings'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install real_settings
    
Run install command and migrate database:

    $ rails g real_settings:install
    $ rake db:migrate
    
## Configuration in config/initializers/real_settings.rb

```ruby
Settings.config do
  settings.app_name = "My Application Name"
  settings.app_url = "http://www.my-application.com"
  default_meta_keywords = "default meta keywords"
  default_meta_description = "default meta description"
  # add some settings here
end
```

## Caution: settings in config/initializers/real_settings.rb can't store in database.

```ruby
Settings.app_name # => "real_settings"
Settings.app_name = "new app name"
Settings.app_name # => "new app name"
Settings.save!
Settings.app_name # => "real_settings"
```
    
## Features & Usage

### RealSettings load default settings from config file
            
```ruby
Settings.config do
  settings.app_name = "My Application Name"
  settings.app_url = "http://www.my-application.com"
  default_meta_keywords = "default meta keywords"
  default_meta_description = "default meta description"
  ......
end

Settings.app_name # => "real_settings"
Settings.app_url # => "http://www.real-settings.com"
Settings.default_meta_keywords # => "default meta keywords"
Settings.default_meta_description # => "default meta description"
```
 
### RealSettings can write settings into database

```ruby
Settings.admin_name # => nil
Settings.admin_name = "Macrow"
Settings.save!
```

### Support has_settings method

```ruby    
class User < ActiveReocrd::Base
  has_settings
end

user = User.first
user.settings.to_hash # => {}
user.settings.email # => nil
user.settings.email = "Macrow_wh@163.com"
user.settings.email # => "Macrow_wh@163.com"
user.settings.to_hash # => { :email => "Macrow_wh@163.com" }
user.save! # save email settings in database

another_user = User.last
another_user.settings.to_hash # => {}
another_user.settings.email # => nil
```
        
### has_settings method with default values

```ruby        
class User < ActiveRecord::Base
  has_settings :defaults => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4' }
end

user = User.first
user.settings.to_hash # => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4' }
user.settings.email # => nil
user.settings.email = "Macrow_wh@163.com"
user.settings.email # => "Macrow_wh@163.com"
user.settings # => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4', :email => "Macrow_wh@163.com" }
user.save! # save email settings in database

another_user = User.last
another_user.settings.to_hash # => { :notebook => 'Macbook Pro', :mobile => 'iPhone 4' }
another_user.settings.email # => nil
```
    
### RealSettings load all settings in memory for performance in first query action

```ruby    
Settings.admin_name # => nil
Settings.admin_name = "Macrow"
Settings.admin_name # => "Macrow"
Settings.reload!
Settings.admin_name # => nil

Settings.admin_name = "Macrow"
Settings.save!
Settings.admin_name # => "Macrow"
Settings.reload!
Settings.admin_name # => "Macrow"
```
        
### Editing Global Settings

```ruby        
# config/routes.rb
get 'settings/edit' => 'settings#edit'
put 'settings/update' => 'settings#update'

# Edit Form:
form_for Settings, :as => :settings, :url => settings_update_path, :method => :put do |f|
  f.text_field :app_name
  f.text_field :app_url
  ......
end

# Update Action:
Settings.update_settings(params[:settings])
```
 
### Editing User's settings

```ruby
# config/routes.rb
resources :users do
  get 'settings/edit' => 'users#edit_settings'
  put 'settings/update' => 'users#update_settings'
end

# User's settings Edit Form:
form_for @user.settings, :as => :settings, :url => user_settings_update_path(@user), :method => :put do |f|
  f.text_field :notebook
  f.text_field :mobile
  ......
end

# Update Action:
@user = User.find(params[:user_id])
@user.settings.update_settings(params[:settings])
```


## License

MIT License.