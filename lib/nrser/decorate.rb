# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using names when resolving methods
require 'nrser/meta/names'


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
  # @param [#to_s] name
  #   The method name, preferably prefixed with `.` or `#` to indicate if it's
  #   a singleton or class method.
  # 
  # @param [nil | :singleton | :class | :instance | #to_sym ] default_type
  #   Identifies singleton/instance methods when the name doesn't.
  #   
  #   `:singleton` and `:class` mean the same thing.
  #   
  #   Tries to convert values to symbols before matching them.
  #   
  #   If `nil`, `name:` **MUST** identify the method type by prefix.
  # 
  # @return [ ::Method | ::UnboundMethod ]
  #   The method object.
  # 
  # @raise [NRSER::ArgumentError]
  #   
  # 
  def resolve_method name:, default_type: nil
    case name
    when Meta::Names::Method::Bare
      bare_name = Meta::Names::Method::Bare.new name
      
      case default_type&.to_sym
      when nil
        raise NRSER::ArgumentError.new \
          "When `default_type:` param is `nil` `name:` must start with '.'",
          "or '#'",
          name: name
          
      when :singleton, :class
        method bare_name
        
      when :instance
        instance_method bare_name
        
      else
        raise NRSER::ArgumentError.new \
          "`default_type:` param must be `nil`, `:instance`, `:singleton` or",
          "`:class`, found", default_type.inspect,
          name: name,
          default_type: default_type
        
      end
    
    when Meta::Names::Method::Singleton
      method Meta::Names::Method::Singleton.new( name ).bare_name
    
    when Meta::Names::Method::Instance
      instance_method Meta::Names::Method::Instance.new( name ).bare_name
    
    else
      raise NRSER::ArgumentError.new \
        "`name:` does not look like a method name:", name.inspect
    end 
  end # #resolve_method
  
  
  def decorate *decorators, target, default_type: nil
    
    name, method_ref = case target
    when ::String, ::Symbol
      [
        target,
        resolve_method( name: target,
                        default_type: ( default_type || :instance ) )
      ]
    when ::UnboundMethod
      [ target.name, target ]
    else
      raise NRSER::ArgumentError.new \
        "`target` (last arg) must be String, Symbol or UnboundMethod",
        "found", target
    end
    
    if default_type.nil?
      default_type = if method_ref.is_a?( ::Method )
        :singleton
      else
        :instance
      end
    end
    
    decorated = \
      decorators.reverse_each.reduce method_ref do |decorated, decorator|
        case decorator
        when ::Symbol, ::String
          decorator = \
            resolve_method \
              name: decorator,
              default_type: default_type
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
  end # decorate
  
  
  def decorate_singleton *args
    decorate *args, default_type: :singleton
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
