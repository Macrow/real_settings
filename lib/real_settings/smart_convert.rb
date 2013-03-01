require 'time'

module RealSettings
  # Just convert simple format for : Time, Array(simple), Float, Fixnum, Boolean, String
  class SmartConvert
    def self.convert(value)
      case value.strip
      when /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4}$/ # Time
        Time.parse(value)
      when /^\[.+\]$/ # Array
        array = []
        value.gsub(/\[|\]/,'').split(',').each {|v| array << RealSettings::SmartConvert.convert(v)}
        array
      when /^\d+\.\d+$/ # Float
        value.to_f
      when /^\d+$/ # Fixnum
        value.to_i
      when 'true'
        true
      when 'false'
        false
      else # String and Others
        value
      end
    end
  end
end