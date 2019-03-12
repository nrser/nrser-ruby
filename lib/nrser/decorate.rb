# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

# Using names when resolving methods
require 'nrser/meta/names'

# Sub-tree
require_relative './decorate/decoration'


# Namespace
# =======================================================================

module  NRSER

# Definitions
# =======================================================================

# Method decoration.
# 
# Check out the {requirements::features::lib::nrser::decorate Features} for
# usage details and examples.
# 
# ## Background
# 
# One part of Python I really liked was method decoration. This is Ruby, so we
# should be able to cook up something nice for, right?
# 
# I searched around online on several occasions, and eventually settled on the
# [method_decorators][] gem, but ended up far from satisfied with it.
# 
# [method_decorators]: https://rubygems.org/gems/method_decorators
# 
# For some color on the issues encountered, check the old spec:
# 
# <https://github.com/nrser/nrser.rb/blob/5762469edf0ccf9c5178f8f16eb6d05ccac614c5/spec/deps/method_decorators/whoops_wrong_method_spec.rb>
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
    name_string = name.to_s # .gsub( /\A\@\@/, '.' ).gsub( /\A\@/, '#' )
    
    case name_string
    when Meta::Names::Method::Bare
      bare_name = Meta::Names::Method::Bare.new name_string
      
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
      method Meta::Names::Method::Singleton.new( name_string ).bare_name
    
    when Meta::Names::Method::Instance
      instance_method Meta::Names::Method::Instance.new( name_string ).bare_name
    
    else
      raise NRSER::ArgumentError.new \
        "`name:` does not look like a method name:", name.inspect
    end 
  end # #resolve_method
  
  
  def decorate *decorators, target, default_type: nil
    
    if decorators.empty?
      raise NRSER::ArgumentError.new "Must provide at least one decorator"
    end
    
    method_ref = case target
    when ::String, ::Symbol
      resolve_method  name: target,
                      default_type: ( default_type || :instance )
    when ::UnboundMethod, ::Method
      target
    else
      raise NRSER::ArgumentError.new \
        "`target` (last arg) must be String, Symbol, Method or UnboundMethod",
        "found", target
    end
    
    if default_type.nil?
      default_type = if method_ref.is_a?( ::Method )
        :singleton
      else
        :instance
      end
    end
    
    decoration = \
      decorators.reverse_each.reduce method_ref do |proto_target, decorator|
        
        # Resolve `decorator` to a `#call`-able if needed
        case decorator
        when ::Symbol, ::String
          decorator = resolve_method  name: decorator,
                                      default_type: default_type
                                      
        when ::Method, ::UnboundMethod
          # pass, it's already good to go
          
        when ::Class
          unless decorator.methods.include? :call
          #   decorator = if decorator.instance_method( :initialize ).parameters.empty?
            decorator = decorator.new
          #   else
          #     decorator.new receiver, 
          end
          
        else
          unless decorator.respond_to? :call
            raise TypeError.new \
              "Expected `decorator` to be one of",
              ::String,
              ::Symbol,
              ::Method,
              ::UnboundMethod,
              ::Class,
              "`#call`",
              "but found", decorator
          end
          
        end # case decorator
        
        Decoration.new decorator: decorator, proto_target: proto_target
        
      end # reduce
    
    definer = case method_ref
    when ::UnboundMethod
      :define_method
    when ::Method
      :define_singleton_method
    else
      raise NRSER::TypeError.new \
        "Expected {UnboundMethod} or {Method}, found", method_ref
    end
    
    send definer, method_ref.name do |*args, &block|
      decoration.call self, *args, &block
    end
    
  end # decorate
  
  
  def decorate_singleton *args
    decorate *args, default_type: :singleton
  end
  
end # module Decorate


# /Namespace
# =======================================================================

end # module NRSER
