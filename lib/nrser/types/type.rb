require 'nrser/refinements'
using NRSER

module NRSER::Types
  class Type
    def self.short_name
      name.split('::').last
    end
    
    def initialize **options
      @name = options[:name]
      @from_s = options[:from_s]
    end
    
    def name
      @name || default_name
    end
    
    def default_name
      self.class.short_name
    end
    
    def test value
      raise NotImplementedError
    end
    
    def check value, &on_fail
      # success case
      return value if test value
      
      msg = if on_fail
        on_fail.call type: self, value: value
      else
        NRSER.squish <<-END
          value #{ value.inspect } failed check #{ self.to_s }
        END
      end
      
      raise TypeError.new msg
    end
    
    def respond_to? name, include_all = false
      if name == :from_s || name == 'from_s'
        has_from_s?
      else
        super name, include_all
      end
    end
    
    def from_s s
      if @from_s.nil?
        raise NoMethodError, "#from_s not defined"
      end
      
      check @from_s.(s)
    end
    
    def has_from_s?
      ! @from_s.nil?
    end
    
    def to_s
      "`Type: #{ name }`"
    end
  end # Type
end # NRSER::Types