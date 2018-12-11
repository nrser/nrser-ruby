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
  
  # Resolve a method name to a reference object.
  # 
  # @example
  #   class A
  def resolve_method name:, default_type: nil
    string_name = name.to_s
    
    unless  default_type.nil? ||
            default_type == :instance ||
            default_type == :singleton ||
            default_type == :class
      raise NRSER::ArgumentError.new \
        "`default_type:` param must be `nil`, `:instance`, `:singleton` or",
        "`:class`, found", default_type
    end
  
    if string_name.start_with? '#'
      instance_method string[ 1..-1 ]
    elsif string_name.start_with? '.'
      method string[ 1..-1 ]
    else
      case default_type
      when nil
        raise NRSER::ArgumentError.new \
          "When `default_type:` param is `nil` `name:` must start with '.'",
          "or '#'",
          name: string_name
      when :instance
        instance_method string_name
      when :singleton, :class
        method string_name
      else
        raise NRSER::UnreachableError.new \
          "Should not be possible given preceding checks of ",
          "`default_type: param`"
      end
    end
  end
  
  
  def decorate *decorators, target
    
    name, method_ref = case target
    when ::String, ::Symbol
      [ target, resolve_method( name: target, default_type: :instance ) ]
    when ::UnboundMethod
      [ target.name, target ]
    else
      raise NRSER::ArgumentError.new \
        "`target` (last arg) must be String, Symbol or UnboundMethod",
        "found", target
    end
    
    decorated = \
      decorators.reverse_each.reduce method_ref do |decorated, decorator|
        case decorator
        when ::Symbol, ::String
          decorator = resolve_method decorator
        when Class
          unless decorator.methods.include? :call
            decorator = decorator.new
          end
        end
        
        Decoration.new decorator: decorator, decorated: decorated
      end
    
    definer = case method_ref
    when UnboundMethod
      :define_method
    when Method
      :define_singleton_method
    else
      raise NRSER::TypeError.new \
        "Expected {UnboundMethod} or {Method}, found", method_ref
    end
    
    send definer, name do |*args, &block|
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
