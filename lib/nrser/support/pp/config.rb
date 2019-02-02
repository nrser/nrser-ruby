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
module PP


# Definitions
# =======================================================================
  
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
      @ivars = IVars.new(  )
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
  

# /Namespace
# =======================================================================

end # module PP
end # module Support
end # module NRSER

