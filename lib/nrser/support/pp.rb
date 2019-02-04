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

#### Sub-Tree ####
require_relative "./pp/config"


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

  module ClassMethods
    def pretty_print_config **kwds
      if instance_variable_defined? :@pretty_print_config
        @pretty_print_config.update!( **kwds ) unless kwds.empty?
      else
        @pretty_print_config ||= Config.new **kwds
      end
      
      @pretty_print_config
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
  # [Ruby 2.0.0 PP::ObjectMixin]: https://docs.ruby-lang.org/en/2.0.0/PP/ObjectMixin.html
  # 
  # This work is targeted at the Pry REPL/debugger, which from what I can tell
  # uses it's {Pry::ColorPrinter} extension:
  # 
  # <https://github.com/pry/pry/blob/v0.12.2/lib/pry/color_printer.rb>
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
            # val.pretty_print(pp)
            pp.pp val
          end # group
          
        end # group
      end # seplist
      
    end # group
    
  rescue Exception => error
    pp.text "!!! ERROR #{ error } !!!"
  end # #pretty_print
  
  
  # def blah pp, obj
  #   id = obj.object_id
  #   if pp.check_inspect_key id
  #     obj.pretty_print_cycle pp
  #     return
  #   end
    
  #   pp.push_inspect_key id
    
  #   obj.pretty_print pp
    
  #   pp.pop_inspect_key id
    
  # end
  
end # module PP


# /Namespace
# =======================================================================

end # module Support
end # module NRSER

