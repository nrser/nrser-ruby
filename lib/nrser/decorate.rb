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
module Decorate
  
  def resolve_decorator_method symbol
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
  
  
  def decorate *decorators, name
    name = name.to_sym
    
    unbound_method = instance_method name
    
    decorated = \
      decorators.reverse_each.reduce unbound_method do |decorated, decorator|
        if decorator.is_a?( Symbol )
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
        decorated.method( :call ).curry receiver
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
