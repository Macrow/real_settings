class Settings < ActiveRecord::Base
  attr_accessible :key, :value, :target_id, :target_type
  @@__settings, @@__file_settings, @@__db_settings, @@__temp_settings = {}, {}, {}, {}
  cattr_accessor :__settings, :__file_settings, :__db_settings, :__temp_settings
  
  class << self
    def config
      yield self
      self.__file_settings = __temp_settings
      reload!
    end
    
    def to_hash
      __settings.dup
    end
    
    def update_settings(attributes)
      if attributes.nil?
        false
      else
        attributes.each { |key, value| send("#{key}=", value) }
        save!
      end
    end
    
    def reload!
      self.__temp_settings = {}
      load!
    end
    
    def save!
      __file_settings.each { |key, value| __settings.delete(key) }
      __settings.delete_if { |key, value| value == __db_settings[key] || __hook_for_delete_owner_default_settings(key, value) }
      __settings.each do |key, value|
        if __db_settings.has_key?(key)
          where(:key => key).first.update_attribute(:value, value)
        else
          create!(:key => key, :value => value, :target_id => target_id, :target_type => target_type)
        end
      end
      __db_settings.merge!(__settings)
      __temp_settings = {}
      calculate_settings
    end
    
    def target_id
      nil
    end
    
    def target_type
      nil
    end
    
    def target_settings
      where(:target_type => target_type).where(:target_id => target_id)
    end
    
    def method_missing(name, *args)
      if self.respond_to?(name)
        super(name, args)
      else
        if name =~ /\w+=$/
          __temp_settings[name.to_s.downcase.gsub('=', '').to_sym] = args.first
          __settings[name.to_s.downcase.gsub('=', '').to_sym] = args.first
        elsif name =~ /\w+/
          __settings[name.to_s.downcase.to_sym] || __hook_for_load_owner_default_settings(name.to_s.downcase.to_sym)
        else
          raise NoMethodError
        end
      end
    end
    
    protected
    
    def __hook_for_load_owner_default_settings(key)
      nil
    end
    
    def __hook_for_delete_owner_default_settings(key, value)
      false
    end
    
    private
    
    def load!
      load_from_database!
      calculate_settings
    end
    
    def calculate_settings # load settings priority is file > database > temp
      self.__settings = self.__temp_settings.merge(self.__db_settings).merge(self.__file_settings)
    end
    
    def load_from_database!
      begin
        __db_settings = {}
        where(:target_type => target_type, :target_id => target_id).order(:key).all.each { |s| self.__db_settings[s.key.to_sym] = s.value }
      rescue
        __db_settings = {}
      end
    end
  end
end