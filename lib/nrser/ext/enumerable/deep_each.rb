# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Enumerable
  
  def deep_each &block
    return enum_for( __method__ ) if block.nil?
    
    each do |entry|
      if entry.respond_to? :deep_each
        entry.deep_each &block
      else
        block.call entry
      end
    end
  end
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
