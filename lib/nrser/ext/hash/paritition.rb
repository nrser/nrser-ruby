# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext
module  Hash


# Definitions
# ========================================================================

# Like {::Array#partition}, but for {Hash}.
# 
# Returns a pair of new {Hash} instances - the first is full of pairs to which
# `&block` responds true when called with those keys and values, and the 
# second pairs to which `&block` responds false.
# 
# @param [::Proc<(::Object, ::Object) → Boolean>] block
#   Called with each `(key, value)` pair, and response is used to determine 
#   which {Hash} to put them in (see above).
# 
# @return [::Array<( ::Hash, ::Hash )>]
# 
def partition &block
  true_hash = {}
  false_hash = {}
  
  each do |key, value|
    if block.call key, value
      true_hash[ key ] = value
    else
      false_hash[ key ] = value
    end
  end
  
  [ true_hash, false_hash ]
end # #partition


# Destructive version of {#partition}.
# 
# @note Destructively mutates `self`.
# 
# @param [::Proc<(::Object, ::Object) → Boolean>] block
#   Called with each `(key, value)` pair; those the response true are deleted
#   from `self` and added to the result hash, those the return false are left
#   in.
# 
# @return [::Hash]
#   Keys and values for which `&block` responded truthfully.
# 
def extract! &block
  {}.tap { |extracted|
    reject! { |key, value|
      if block.call key, value
        extracted[ key ] = value
        true
      end
    }
  }
end


# /Namespace
# ========================================================================

end # module Hash
end # module Ext
end # module NRSER
