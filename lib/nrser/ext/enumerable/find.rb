# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/errors/argument_error'
require 'nrser/errors/multiple_errors'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Enumerable
  
  # Find the first truthy (not `nil` or `false`) result of calling `&block`
  # on entries.
  # 
  # Like {Enumerable#find}, accepts an optional `ifnone` procedure to call if
  # no match is found.
  # 
  # @example
  #   
  #   [1, 2, 3, 4].find_map do |i|
  #     if i.even?
  #       "#{ i } is even!"
  #     end
  #   end
  #   # => "2 is even!"
  # 
  # @param [nil | Proc<()=>DEFAULT>] ifnone
  #   Optional lambda to call for the return value when no match is found.
  # 
  # @param [Proc<(E)=>RESLUT>] block
  #   Block mapping entires to results.
  # 
  # @return [nil]
  #   When `block.call( E )` is `nil` or `false` for all entries `E`
  #   *and* `ifnone` is `nil` or not provided.
  # 
  # @return [V]
  #   When `block.call( E )` is `nil` or `false` for all entries `E`
  #   *and* `ifnone` is a lambda that returns `DEFAULT`.
  # 
  # @return [RESULT]
  #   The first result `RESLUT = block.call( E )`
  #   where `RESLUT` is not `nil` or `false`.
  # 
  # @return [DEFAULT]
  #   When `ifnone` procedure is provided and `&block` returns `nil` or
  #   `false` for all entries.
  # 
  # @return [nil]
  #   When `ifnone` procedure is *not* provided and `&block` returns `nil` or
  #   `false` for all entries.
  # 
  def find_map ifnone = nil, &block
    each do |entry|
      if result = block.call( entry )
        # Found a match, short-circuit
        return result
      end
    end
    
    # No matches, return `ifnone`
    ifnone.call if ifnone
  end # #find_map


  # Find all entries in an {Enumerable} for which `&block` returns a truthy
  # value, then check the amount of results found against the
  # {NRSER::Types.length} created from `bounds`, raising a
  # {NRSER::Types::CheckError} if the results' length doesn't satisfy the bounds
  # type.
  # 
  # @param [Integer | Hash] bounds
  #   Passed as only argument to {NRSER::Types.length} to create the length
  #   type the results are checked against.
  # 
  # @param [Proc] block
  #   `#find`/`#find_all`-style block that will be called with each entry
  #   from `self`. Truthy responses mean the entry matched.
  # 
  # @return [Array]
  #   Found entries from `self`.
  # 
  # @raise [NRSER::Types::CheckError]
  #   If the results of `#find_all &block` don't satisfy `bounds`.
  # 
  def find_bounded! bounds, &block
    require 'nrser/types'
    
    Types.
      length( bounds ).
      check!( find_all &block ) { |type:, value:|
        raise Types::CheckError.new \
          "Length of found elements", value.length, "FAILED to satisfy",
          "bounds conditions", type,
          value: value,
          type: type,
          enumerable: self
      }
  end # #find_bounded!


  # Version of {#find_bounded!} that returns `nil` if the find results don't 
  # meet the `bounds` conditions.
  # 
  # @param (see #find_bounded!)
  # @return (see #find_bounded!)
  # 
  # @return [nil]
  #   If `bounds` are not met by find results.
  # 
  def find_bounded bound, &block
    require 'nrser/types'
    
    n_x.find_bounded! bound, &block
  rescue Types::CheckError => error
    nil
  end # #find_bounded
  
  
  # Find the only entry for which `&block` responds truthy, raising
  # if either no entries or more than one are found.
  # 
  # Returns the entry itself, not an array of length 1.
  # 
  # Just calls {NRSER.find_bounded} with `bounds = 1`.
  # 
  # @param &block (see NRSER.find_bounded)
  # 
  # @return [E]
  #   Only entry in `enum` that `&block` matched.
  # 
  # @raise [TypeError]
  #   If `&block` matched more or less than one entry.
  # 
  def find_only! &block
    n_x.find_bounded!( 1, &block ).first
  end # .find_only


  # Version of {#find_only!} that returns `nil` if more or less than one entry
  # is found.
  # 
  # @note
  #   If `self` contains a single `nil` and `nil` may be matched by by `&block`
  #   then it will not be possible to distinguish between that `nil` being the
  #   single found result and more or less than one result being found.
  #   
  #   Hope that sort of makes some sense.
  # 
  # @param (see #find_only!)
  # 
  # @return [Object]
  #   When `&block` matches exactly one entry.
  # 
  # @return [nil]
  #   When `&block` matches more or less than one entry.
  #   
  def find_only &block
    require 'nrser/types'
    
    n_x.find_only! &block
  rescue NRSER::Types::CheckError => error
    nil
  end
  
  
  # Return the first entry if `#count` is one.
  # 
  # Otherwise, return `default` (which defaults to `nil`).
  # 
  # @param [D] default
  #   Value to return if `enum` does not have only one entry.
  # 
  # @return [E]
  #   When `enum` has `#count == 1`.
  # 
  # @return [D]
  #   When `enum` does not have `#count == 1`.
  # 
  def only default: nil
    if count == 1
      first
    else
      default
    end
  end # .only
  
  
  # Return the only entry if `#count` is one. Otherwise raise an error.
  # 
  # @return [E]
  #   First element of `enum`.
  # 
  # @raise [ArgumentError]
  #   If `enum` does not have `#count == 1`.
  # 
  def only!
    count = self.count
    
    unless count == 1
      raise CountError.new value: self,
                                  count: count,
                                  expected: 1
    end
    
    first
  end # .only!


  # Like `Enumerable#find`, but wraps each call to `&block` in a
  # `begin` / `rescue`, returning the result of the first call that doesn't
  # raise an error.
  # 
  # If no calls succeed, raises a {NRSER::MultipleErrors} containing the
  # errors from the block calls.
  # 
  # @param [Enumerable<E>] enum
  #   Values to call `&block` with.
  # 
  # @param [Proc<E=>V>] block
  #   Block to call, which is expected to raise an error if it fails.
  # 
  # @return [V]
  #   Result of first call to `&block` that doesn't raise.
  # 
  # @raise [NRSER::ArgumentError]
  #   If `enum` was empty (`enum#each` never yielded).
  # 
  # @raise [NRSER::MultipleErrors]
  #   If all calls to `&block` failed.
  # 
  def try_find &block
    errors = []
    
    each do |*args|
      begin
        result = block.call *args
      rescue ::Exception => error
        errors << error
      else
        return result
      end
    end
    
    if errors.empty?
      raise ArgumentError,
        "Appears that enumerable was empty: #{ inspect }"
    else
      raise MultipleErrors.new errors
    end
  end # .try_find
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
