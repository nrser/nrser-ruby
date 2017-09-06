require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/combinators'

using NRSER
  
module NRSER::Types
  class Attrs < NRSER::Types::Type
    def initialize attrs, **options
      super **options
      @attrs = attrs
    end
    
    def default_name
      attrs_str = @attrs.map {|name, type|
        "#{ name }=#{ type.name }"
      }.join(', ')
      
      "#{ self.class.short_name } #{ attrs_str }"
    end
    
    def test value
      @attrs.all? {|name, type|
        value.respond_to?(name) && type.test(value.method(name).call)
      }
    end
  end # Attrs
  
  def self.attrs attrs, options = {}
    Attrs.new attrs, **options
  end
  
  def self.length *args
    bounds = {}
    options = {}
    
    case args.length
    when 1
      case args[0]
      when ::Integer
        bounds[:min] = bounds[:max] = non_neg_int.check(args[0])
        
      when ::Hash
        options = NRSER.symbolize_keys args[0]
        
        bounds[:min] = options.delete :min
        bounds[:max] = options.delete :max
        
        if length = options.delete(:length)
          bounds[:min] = length
          bounds[:max] = length
        end
        
      else        
        raise ArgumentError, <<-END.squish
          arg must be positive integer or option hash, found:
          #{ args[0].inspect } of type #{ args[0].class }
        END
      end
      
    when 2
      bounds[:min] = bounds[:max] = non_neg_int.check(args[0])
      options = args[1]
      
    else
      raise ArgumentError, <<-END.squish
        must provided 1 or 2 args.
      END
    end
    
    bounded_type = bounded bounds
    
    length_type = if !bounded_type.min.nil? && bounded_type.min >= 0
      # We don't need the non-neg check
      bounded_type
    else
      # We do need the non-neg check
      intersection(non_neg_int, bounded_type)
    end
    
    options[:name] ||= "Length<#{ bounded_type.name }>"
    
    attrs({ length: length_type }, options)
  end
end # NRSER::Types