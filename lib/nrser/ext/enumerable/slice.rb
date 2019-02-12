# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need {NRSER::Ext::Enumerable::Associate#assoc_by}
require_relative './associate'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Enumerable
  
  # See if an `enum` includes a `slice`, using an optional block to do custom
  # matching.
  # 
  # @example Order matters
  #   [1, 2, 3].n_x.slice? [2, 3]
  #   # => true
  #   
  #   [1, 2, 3].n_x.slice? [3, 2]
  #   # => false
  # 
  # @example The empty slice is always present
  #   [1, 2, 3].n_x.slice? []
  #   # => true
  #   
  #   [].n_x.slice? []
  #   # => true
  # 
  # @example Custom `&is_match` block to prefix-match
  #   ['neil', 'mica', 'hudie'].
  #     n_x.
  #     slice?( ['m', 'h'] ) { |self_entry, slice_entry|
  #       self_entry.start_with? slice_entry
  #     }
  #   # => true
  # 
  # @note
  #   Right now, just forwards to {NRSER.array_include_slice?}, which requires
  #   that the {Enumerable}s support {Array}-like `#length` and `#slice`. I
  #   took a swing at the general case but it came out messy and only partially
  #   correct.
  # 
  # @param [Enumerable] enum
  #   Sequence to search in.
  # 
  # @param [Enumerable] slice
  #   Slice to search for.
  # 
  # @return [Boolean]
  #   `true` if `enum` has a slice matching `slice`.
  # 
  def slice? slice, &is_match
    # Check that both args are {Enumerable}
    unless slice.is_a?( ::Enumerable )
      raise NRSER::TypeError.new \
        "`slice` must be an {Enumerable}",
        slice_class: slice.class,
        slice: slice
    end
    
    if [self, slice].all? { |e|
      e.respond_to?( :length ) && e.respond_to?( :slice )
    }
      return n_x.array_slice? slice, &is_match
    end
    
    raise NotImplementedError.new <<~END
      Sorry, but general {Enumerable} slice include has not been implemented
      
      It's kinda complicated, or at least seems that way at first, so I'm
      going to punt for now...
    END
  end


  # Test slice inclusion when both the `slice` and the `enum` that we're
  # going to look for it in support `#length` and `#slice`
  # in the same manner that {Array} does (hence the name).
  # 
  # This is much simpler and more efficient than the "general" {Enumerable}
  # case where we can't necessarily find out how many entries are in the
  # enumerables or really do much of anything with them except iterate through
  # (at least, with my current grasp of {Enumerable} and {Enumerator} it
  # seems painfully complex... in fact it may never terminate for infinite
  # enumerables).
  # 
  # @param [Enumerable<E> & #length & #slice] enum
  #   The {Enumerable} that we want test for `slice` inclusion. Must
  #   support `#length` and `#slice` like {Array} does.
  # 
  # @param [Enumerable<S> & #length & #slice] slice
  #   The {Enumerable} slice that we want to see if `enum` includes. Must
  #   support `#length` and `#slice` like {Array} does.
  # 
  # @param [Proc<(E, S)=>Boolean>] is_match
  #   Optional {Proc} that accepts an entry from `enum` and an entry from
  #   `slice` and returns if they match.
  # 
  # @return [Boolean]
  #   `true` if there is a slice of `enum` for which each entry matches the
  #   corresponding entry in `slice` according to `&is_match`.
  # 
  def array_slice? slice, &is_match
    slice_length = slice.length
    
    # Short-circuit on empty slice - it's *always* present
    return true if slice_length == 0
    
    length = self.length
    
    # Short-circuit if slice is longer than enum since we can't possibly
    # match
    return false if slice_length > length
    
    # Create a default `#==` matcher if we weren't provided one.
    if is_match.nil?
      is_match = ->(self_entry, slice_entry) {
        self_entry == slice_entry
      }
    end
    
    each_with_index do |self_entry, self_start_index|
      # Compute index in `self` that we would need to match up to
      self_end_index = self_start_index + slice_length - 1
      
      # Short-circuit if can't match (more slice entries than enum ones left)
      return false if self_end_index >= length
      
      # Create the slice to test against
      self_slice = self[self_start_index..self_end_index]
      
      # See if every entry in the slice from `self` matches the corresponding
      # one in `slice`
      return true if self_slice.zip( slice ).all? { |(self_entry, slice_entry)|
        is_match.call self_entry, slice_entry
      }
      
      # Otherwise, just continue on through `enum` looking for that first
      # match until the number of `enum` entries left is too few for `slice`
      # to possibly match
    end
    
    # We never matched the first `slice` entry to a `enum` entry (and `slice`
    # had to be of length 1 so that the "too long" short-circuit never fired).
    # 
    # So, we don't have a match.
    false
  end
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
