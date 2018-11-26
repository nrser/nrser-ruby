# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER

# Definitions
# =======================================================================

# @todo document Decorate module.
# 
# @see requirements::features::lib::nrser::decorate Features
# 
module Decorate
  
  def resolve_decorator_method symbol
    symbol = symbol.to_sym unless symbol.is_a?( ::Symbol )
    
    if instance_methods.include? symbol
      instance_method symbol
    elsif methods.include? symbol
      method symbol
    else
      raise NoMethodError,
            "Symbol #{ symbol.inspect } does not seem to be an instance or " +
            "singleton method"
    end
  end
  
  
  def decorate *decorators, target
    
    name, unbound_method = case target
    when ::String, ::Symbol
      [ target, instance_method( target ) ]
    when ::UnboundMethod
      [ target.name, target ]
    else
      raise NRSER::ArgumentError.new \
        "`target` (last arg) must be String, Symbol or UnboundMethod",
        "found", target
    end
    
    decorated = \
      decorators.reverse_each.reduce unbound_method do |decorated, decorator|
        if decorator.is_a?( ::Symbol ) || decorator.is_a?( ::String )
          decorator = resolve_decorator_method( decorator ) 
        end
        
        Decoration.new decorator: decorator, decorated: decorated
      end
    
    define_method name do |*args, &block|
      decorated.call self, *args, &block
    end
  end
  
  
  class Decoration
    attr_reader :decorator
    attr_reader :decorated
    
    def initialize decorator:, decorated:
      @decorator = decorator
      @decorated = decorated
    end
    
    def call receiver, *args, &block
      target = case decorated
      when Decoration
        # decorated.method( :call ).curry receiver
        ->( *a, &b ) { decorated.call receiver, *a, &b }
      when UnboundMethod 
        decorated.bind receiver
      when Symbol
        receiver.method decorated
      else
        decorated
      end
      
      
      decorator = if self.decorator.is_a? UnboundMethod
        self.decorator.bind receiver
      else
        self.decorator
      end
      
      decorator.call receiver, target, *args, &block
    end
  end
  
end # module Decorate


# /Namespace
# =======================================================================

end # module NRSER
