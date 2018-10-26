# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Hash

  # Just like {Hash#transform_values} but yields `key, value` instead of just
  # `value` so that you can use the key as well when deciding what new value
  # to produce.
  # 
  # @param [Proc<(KEY, VALUE) -> NEW_VALUE>] block
  #   Called with each key/value pair. The response will be that key's value in
  #   the result.
  # 
  # @return [Hash<KEY, NEW_VALUE>]
  # 
  def transform_values_with_keys &block
    return enum_for( __method__ ) { size } unless block_given?
    return {} if empty?
    result = self.class.new
    each do |key, value|
      result[key] = block.call key, value
    end
    result
  end
  
  
  # Just like {#transform_values_with_keys} but mutates `self`.
  # 
  # @param [Proc<(KEY, VALUE) -> NEW_VALUE>] block
  #   Called with each key/value pair. The response will be that key's value in
  #   the result.
  # 
  # @return [Hash<KEY, NEW_VALUE>]
  # 
  def transform_values_with_keys! &block
    return enum_for( __method__ ) { size } unless block_given?
    each do |key, value|
      self[key] = block.call key, value
    end
  end
  
end # module Hash


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
