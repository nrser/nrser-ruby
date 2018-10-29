# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# ========================================================================

module Object

  # Treat this object as the value for `key` in a hash if it's not already a
  # hash and can't be converted to one:
  # 
  # 1.  If `self` is a `Hash`, return it.
  #     
  # 2.  If `self` is `nil`, return `{}`.
  #     
  # 3.  If `self` responds to `#to_h` and `#to_h` succeeds, return the
  #     resulting hash.
  #     
  # 4.  Otherwise, return a new hash where `key` points to `self`.
  #     **`key` MUST be provided in this case.**
  # 
  # Useful in method overloading and similar situations where you expect a
  # hash that may specify a host of options, but want to allow the method
  # to be called with a single value that corresponds to a default key in that
  # option hash.
  # 
  # Example Time!
  # -------------
  # 
  # Say you have a method `m` that handles a hash of HTML options that can
  # look something like
  # 
  #     {class: 'address', data: {confirm: 'Really?'}}
  # 
  # And can call `m` like
  # 
  #     m({class: 'address', data: {confirm: 'Really?'}})
  # 
  # but often you are just dealing with the `:class` option. You can use
  # `#as_hash` to accept a string and treat it as the `:class` key:
  # 
  #     def m opts
  #       opts = opts.n_x.as_hash :class
  #       # ...
  #     end
  # 
  # If you pass a hash, everything works normally, but if you pass a string
  # `'address'` it will be converted to `{class: 'address'}`.
  # 
  # 
  # About `#to_h` Support
  # ---------------------
  # 
  # Right now, {.as_hash} also tests if `self` responds to `#to_h`, and will
  # try to call it, using the result if it doesn't raise. This lets it deal
  # with Ruby's "I used to be a Hash until someone mapped me" values like
  # `[[:class, 'address']]`. I'm not sure if this is the best approach, but
  # I'm going to try it for now and see how it pans out in actual usage.
  # 
  # @todo
  #   It might be nice to have a `check` option that ensures the resulting
  #   hash has a value for `key`.
  # 
  # @param [Object] key [default nil]
  #   The key that `self` will be stored under in the result if `self` is
  #   not a hash or can't be turned into one via `#to_h`. If this happens
  #   this value can **NOT** be `nil` or an `ArgumentError` is raised.
  # 
  # @return [Hash]
  # 
  # @raise [ArgumentError]
  #   If it comes to constructing a new Hash with `self` as a value and no
  #   argument was provided
  # 
  def as_hash key = nil
    return self if is_a? Hash
    return {} if nil?
    
    if respond_to? :to_h
      begin
        return to_h
      rescue
        # pass
      end
    end
    
    # at this point we need a key argument
    if key.nil?
      raise ArgumentError,
            "Need key to construct hash with value #{ inspect }, " +
            "found nil."
    end
    
    { key => self }
  end # #as_hash
  
  
  # Return an array in the way that makes most sense:
  # 
  # 1.  If `self` is an array, return it.
  #     
  # 2.  If `self` is `nil`, return `[]`.
  #     
  # 3.  If `self` responds to `#to_a`, try calling it. If it succeeds, return
  #     that.
  #     
  # 4.  Return an array with `self` as it's only item.
  # 
  # @return [Array]
  # 
  def as_array
    return self if is_a? ::Array
    return [] if nil?
    
    if respond_to? :to_a
      begin
        return to_a
      rescue
        #pass
      end
    end
    
    [ self ]
  end # #as_array
  
  
end # module Object


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
