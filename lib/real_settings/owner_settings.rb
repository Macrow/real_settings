class OwnerSettings < Settings
  @@__owner_settings, @@__owner_db_settings, @@__owner_temp_settings, @@__owner_loaded, @@__owner_default_settings  = {}, {}, {}, {}, {}
  
  class << self
    def get_settings(owner, defaults)
      @owner = owner
      @@__owner_settings[owner_symbol] ||= {}
      @@__owner_db_settings[owner_symbol] ||= {}
      @@__owner_temp_settings[owner_symbol] ||= {}
      @@__owner_default_settings[owner_type_symbol] ||= ( defaults || {} )
      if @@__owner_loaded[owner_symbol].nil?
        reload!
        @@__owner_loaded[owner_symbol] = true
      end
      self
    end
    
    def to_hash
      @@__owner_default_settings[owner_type_symbol].merge(__settings).dup
    end
    
    def target_id
      @owner.id
    end
    
    def target_type
      @owner.class.base_class.to_s
    end
    
    def owner_type_symbol
      target_type.downcase.to_sym
    end
    
    def owner_symbol
      "#{target_type}_#{target_id}".downcase.to_sym
    end
    
    def reload!
      super
      __settings
    end
    
    def __settings
      @@__owner_settings[owner_symbol]
    end
    
    def __settings=(value)
      @@__owner_settings[owner_symbol] = value
    end

    def __file_settings
      {}
    end
    
    def __file_settings=(value)
      {}
    end

    def __db_settings
      @@__owner_db_settings[owner_symbol]
    end
    
    def __db_settings=(value)
      @@__owner_db_settings[owner_symbol] = value
    end

    def __temp_settings
      @@__owner_temp_settings[owner_symbol]
    end
    
    def __temp_settings=(value)
      @@__owner_temp_settings[owner_symbol] = value
    end
    
    protected
    
    def __hook_for_load_owner_default_settings(key)
      @@__owner_default_settings[owner_type_symbol][key]
    end
    
    def __hook_for_delete_owner_default_settings(key, value)
      value == @@__owner_default_settings[owner_type_symbol][key]
    end
  end
end