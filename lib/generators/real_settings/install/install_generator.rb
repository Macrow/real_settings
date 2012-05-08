module RealSettings
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path('../templates', __FILE__)
    desc "Install RealSettings for your application."

    def copy_initializers_files
      template "real_settings.rb", "config/initializers/real_settings.rb"
    end

    def copy_migration_files
      migration_template "migration.rb", "db/migrate/create_real_settings.rb"
    end

   def self.next_migration_number(dirname)
     if ActiveRecord::Base.timestamped_migrations
       Time.now.utc.strftime("%Y%m%d%H%M%S")
     else
       "%.3d" % (current_migration_number(dirname) + 1)
     end
   end
   
   
   
  end
end