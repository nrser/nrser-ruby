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
  
  # Considering this instance as a pair of values return an {::Enumerable} of
  # {::Enumerable#count} `2` containing them.
  #
  # At least that's the best technical explanation I can come up with at the
  # moment. In practical terms, use this method when you have either an
  # {::Array} of length 2 or a {::Hash} of length 1 and you want to normalize it
  # into an {::Array} of length 2.
  #
  # However, this method is written to be general enough that it should also
  # work on a wide-range of enumerables, as long as hash-like classes respond to
  # `#each_pair` and do so with enumerables of count 2.
  #
  # If this instance is not "hash-like" and is already of count 2 it is simply
  # returned.
  # 
  # @example From a {Hash}
  #   { key: 'value' }.n_x.to_pair
  #   #=> [:key, 'value']
  # 
  # @example From an {Array}
  #   [ :key, 'value' ].n_x.to_pair
  #   #=> [:key, 'value']
  # 
  # @example From an {Enumerator}
  #   2.times.n_x.to_pair.to_a
  #   #=> [1, 2]
  # 
  # @return [Enumerable<(KEY, VALUE)>]
  #   {::Enumerable} of count 2, the first entry being the "key", and the 
  #   second being the "value".
  # 
  # @raise [NRSER::TypeError]
  #   If this instance does not have a pair structure.
  # 
  def to_pair
    count = self.count

    if respond_to? :each_pair
      # Handle {Hash}-like

      unless count == 1
        raise NRSER::TypeError.new \
          "{::Enumerable} responds to `#each_pair` but does not have count 1",
          count: count,
          self: self
      end

      first = self.first
      first_count = first.count

      unless first.is_a?( ::Enumerable ) && first_count == 2
        raise NRSER::TypeError.new \
          "`#first` entry is not an {::Enumerable} of count 2",
          first_entry: first,
          first_count: first_count,
          self: self
      end

      first
    else
      # Handle non-{Hash}-like

      unless count == 2
        raise NRSER::TypeError.new \
          "{::Enumerable} does not respond to `#each_pair` and does not have",
          "count 2",
          count: count,
          self: self
      end

      self
    end
  end
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
