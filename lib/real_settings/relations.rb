ActiveRecord::Base.class_eval do
  def self.has_settings(*args)
    cattr_accessor :__default_settings_options
    self.__default_settings_options = args.extract_options![:defaults]
    
    class_eval do
      def settings
        OwnerSettings.get_settings(self, __default_settings_options)
      end
      after_save {|owner| owner.settings.save!}
      after_destroy {|owner| owner.settings.target_settings.each {|s| s.destroy}}
    end
  end
end