# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

# Besides just needing `pp` if you intend to do any pretty printing, we need
# it to make {::Object.pretty_print} calls
require 'pp'

### Deps ###

# Using {::Object#present?}
require 'active_support/core_ext/object/blank'

# Using {::String#truncate}
require 'active_support/core_ext/string/filters'


# Namespace
# =======================================================================

module  NRSER
module  Support


# Definitions
# =======================================================================

# @todo document PP module.
# 
module PP
  
  class ErrorString < ::String
    DEFAULT_TRUNCATE_LENGTH = 20
  
    def initialize cause, error, truncate_to: DEFAULT_TRUNCATE_LENGTH
      super(
        "!!! PRETTY PRINT ERROR #{ cause }: " +
        error.to_s.truncate( truncate_to ) +
        " !!!"
      )
    end
    
    def blank?
      true
    end
    
    def present?
      false
    end
  end
  
  class Config
    
    def initialize
      @ivars = true
      @methods = []
    end
    
    def update! **kwds
      set_ivars!( kwds[ :ivars ] ) if kwds.key?( :ivars )
      set_methods!( kwds[ :methods ] ) if kwds.key?( :methods )
      self
    end
    
    
    # @example
    #   
    #       NRSER::Support::PP::Config.new.set_ivars! \
    #           
    def set_ivars! arg
      case arg
      when true, false, :always, :never, :present
        @ivars = arg
      when ::Hash
        @ivars = []
        
        if arg.key? :always
        end
        
      end
    end
    
    
    def set_methods! arg
      @methods = []
      
      if arg != false
        
        if arg.key? :always
          @methods += \
            arg[ :always ].
              map { |method_name| [ method_name.to_sym, :always ] }
        end
        
        if arg.key? :present
          @methods += \
            arg[ :present ].
              map { |method_name| [ method_name.to_sym, :present ] }
        end
        
        @methods.sort!
      end
      
      self
    end # #methods=
    
    
    def method_value_for instance, method_name
      instance.send method_name
      
    rescue Exception => error
      ErrorString.new "calling `.#{ method_name }`", error
      
    end # #method_value_for
    
    
    def ivar_value_for instance, ivar_name
      instance_variable_get ivar_name
    rescue Exception => error
      ErrorString.new( "getting ivar #{ ivar_name }", error )
    end
    
    
    def values_for_ivars instance, add_to: []
      add_to.tap do |values|
        case @ivars
        
        when true, :always
          pretty_print_instance_variables.each do |ivar_name|
            values << [ ivar_name, ivar_value_for( instance, ivar_name ) ]
          end
          
        when ::Array
          @ivars.each do |ivars_entry|
          
            case ivars_entry
            
            when ::String, ::Symbol
              values << [ ivars_entry,
                          ivar_value_for( instance, ivars_entry ) ]
              
            when ::Array
              begin
                ivar_name, ivar_mode = ivars_entry
              rescue Exception => error
                # Can't do much here except log it or some shit
              else
                case ivar_mode
                when false, :never
                  # pass
                when true, :always
                  values << [ ivar_name,
                              ivar_value_for( instance, ivar_name ) ]
                when :present
                  value = ivar_value_for instance, ivar_name 
                  values << [ ivar_name, value ] if value.present?
                end
              end # begin; destructure name/mode; rescue
              
            else
              # TODO  Log an error?
            end # case ivars_entry
            
          end # @ivars.each
        
        end # case @ivars
      end # add_to.tap
    end # #values_for_ivars
    
    
    def values_for_methods instance, add_to: []
      add_to.tap do |values|
        @methods.each do |(method_name, include_when)|
          value = method_value_for instance, method_name
          
          if  include_when == :always ||
              ( include_when == :present && value.present? )
            values << [ method_name, value ]
          end
        end # @methods.each_with_object
      end # add_to.tap
    end
    
    
    def values_for instance, add_to: []
      add_to.tap do |values|
        values_for_ivars instance, add_to: values
        values_for_methods instance, add_to: values
      end # [].tap |values|
    end # #values_for
    
  end # class Config
  

  module ClassMethods
    def pretty_print_config **kwds
      @pretty_print_config ||= Config.new
      
      @pretty_print_config.update!( **kwds ) unless kwds.empty?
      
      @pretty_print_config
    end
  
    def pretty_print_methods= **kwds
      pretty_print_config.methods = kwds
    end
  end # module ClassMethods
  
  
  module InstanceMethods
    #
    def pretty_print_values
      self.class.pretty_print_config.values_for self
    end
  end # module InstanceMethods
  
  
  # Singleton Methods
  # ==========================================================================
  
  # Hooks
  # --------------------------------------------------------------------------
  
  def self.included base
    if base.is_a?( ::Class )
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end
  end # .included
  
  
  # Instance Methods
  # ==========================================================================
  
  # Override `#pretty_print` to provide what I hope is a clearer and more 
  # useful formatting, aimed at Pry sessions and developed when working on
  # {NRSER::Described}, where description hierarchies and resolutions lead to
  # huge object trees that I'm often needing to sift through.
  # 
  # Sans-experience, I'm finding pretty printing a bit cryptic and confusing,
  # without much for guides or examples in the Ruby docs or around the net,
  # so what follows is essentially my implementation notes as I stumble 
  # through it...
  # 
  # The built in method is at `::PP::ObjectMixin#pretty_print`, which is now
  # `:nodoc:` in the Ruby source code (though it used to be doc'd in `2.0.0`,
  # see [Ruby 2.0.0 PP::ObjectMixin][]), but the source (for 2.3.7) can be 
  # found at:
  # 
  # <https://github.com/ruby/ruby/blob/v2_3_7/lib/pp.rb#L309>
  # 
  # 
  # [Ruby 2.0.0 PP::ObjectMixin]: https://docs.ruby-lang.org/en/2.0.0/PP/ObjectMixin.html
  # 
  # @see https://ruby-doc.org/stdlib-2.3.7/libdoc/prettyprint/rdoc/PrettyPrint.html
  # @see https://ruby-doc.org/stdlib-2.3.7/libdoc/pp/rdoc/PP.html
  # @see https://ruby-doc.org/stdlib-2.3.7/libdoc/pp/rdoc/PP/PPMethods.html
  # 
  # @param [::PrettyPrint] pp 
  #   The pretty printer that gets passes around to generate the output.
  # 
  # @return [void]
  #   I don't think it matters? Formatting is accomplished by calling methods
  #   on `pp` and passing it to other object's `#pretty_print` methods.
  # 
  def pretty_print pp
    # {PrettyPrint#group}
    # 
    #     group(
    #       indent      = 0,
    #       open_obj    = '',
    #       close_obj   = '',
    #       open_width  = open_obj.length,
    #       close_width = close_obj.length
    #     )
    # 
    # https://ruby-doc.org/stdlib-2.3.7/libdoc/prettyprint/rdoc/PrettyPrint.html#method-i-group
    # 
    pp.group 1, "{#{self.class}", "}" do
      pp.breakable ' '
      
      pp.seplist pretty_print_values,  nil do |(name, val)|
        pp.group do
          pp.text "#{ name }: "
          
          pp.group 1 do
            pp.breakable ''
            val.pretty_print(pp)
          end # group
          
        end # group
      end # seplist
      
    end # group
  end # #pretty_print
  
end # module PP


# /Namespace
# =======================================================================

end # module Support
end # module NRSER

