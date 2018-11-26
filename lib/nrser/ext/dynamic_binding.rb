# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/sugar/method_missing_forwarder'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module DynamicBinding

  def self.logger
    NRSER::Log[ self ] # .tap { |l| l.level = :trace }
  end

  def self.resolve receiver, method_name
    method_name = method_name.to_sym unless method_name.is_a?( Symbol )

    logger.trace "RESOLVING",
      receiver: receiver,
      method_name: method_name
    
    if receiver.is_a? ::Module
      logger.trace "receiver is a {::Module}, so checking that first..."

      if  receiver.name &&
          NRSER::Ext.const_defined?( receiver.name, false )
        mod = NRSER::Ext.const_get receiver.name

        if mod.const_defined? :ClassMethods
          class_methods_module = mod.const_get :ClassMethods

          if  class_methods_module.
                instance_methods( false ).
                include? method_name
            resolved = class_methods_module.instance_method method_name

            logger.trace "RESOLVED to class method!",
              receiver: receiver,
              method_name: method_name,
              module: class_methods_module,
              class_method: resolved
            
            return resolved
          end
        end
      end
    end

    receiver.singleton_class.ancestors.each do |ancestor|
      logger.trace "CHECKING",
        ancestor: ancestor
      
      unless ancestor.name
        logger.trace "NEXT - ancestor has no name",
          ancestor: ancestor,
          name: ancestor.name
        next
      end

      unless NRSER::Ext.const_defined?( ancestor.name, false )
        logger.trace "NEXT - {NRSER::Ext} has no #{ ancestor.name } constant",
          ancestor: ancestor,
          name: ancestor.name
        next
      end

      const = NRSER::Ext.const_get ancestor.name

      logger.trace "GOT CONST",
        ancestor: ancestor,
        const: const

      unless const.is_a?( Module )
        logger.trace "NEXT - const is not a {::Module}",
          const: const,
          const_class: const.class
        next
      end

      unless const.instance_methods.include? method_name
        logger.trace "NEXT - const has no ##{ method_name } method",
          const: const,
          method_name: method_name
        next
      end
      
      resolved = const.instance_method method_name

      logger.trace "RESOLVED!",
        receiver: receiver,
        method_name: method_name,
        ancestor: ancestor,
        const: const,
        instance_method: resolved

      return resolved
    end

    raise NameError,
          "Couldn't find #{ method_name } for #{ receiver }:#{ receiver.class }"
  end


  def nrser_ext_call name, *args, &block
    DynamicBinding.resolve( self, name ).bind( self ).call *args, &block
  end


  def nrser_ext
    NRSER::MethodMissingForwarder.new do |name, *args, &block|
      nrser_ext_call name, *args, &block
    end
  end


  # Short name
  alias_method :n_x, :nrser_ext
  
end # module DynamicBinding


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER