# Hack for simple_form auto column type detectation
module RealSettings
  class FakeColumn
    attr_accessor :type, :number
    
    def initialize(type, number = false)
      self.type = type.downcase.to_sym
      self.number = number
    end
    
    def number?
      number
    end
    
    def limit
      if type == 'string'
        255
      else
        nil
      end
    end
  end
end