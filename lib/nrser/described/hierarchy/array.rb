# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative '../hierarchy'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Hierarchy


# Definitions
# =======================================================================

# A {Hierarchy} implementation that simply stores descriptions in an {::Array},
# sorting from most to least recently added or touched.
# 
# Used in Cucumber, which so far doesn't require anything more complicated.
# 
class Array
  
  # Mixins
  # ========================================================================
  
  include Hierarchy
  
  
  # Access to the underlying storage, for debugging purposes.
  # 
  # @return [attr_type]
  #     
  attr_reader :storage
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new {Hierarchy::Array}.
  # 
  def initialize
    @storage = []
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  # Add a {Described::Base} to the hierarchy. It will become {#current} and 
  # first in {#each}.
  # 
  # @see Hierarchy#add
  # @param  (see Hierarchy#add)
  # @return (see Hierarchy#add)
  # 
  def add described
    @storage << described
  end
  
  
  # Iterate the descriptions in from most to least recent added or touched.
  # 
  # @see Hierarchy#each
  # 
  # @overload each
  #   
  #   @return [::Enumerator<Described::Base>]
  #     That iterates over the descriptions.
  # 
  # @overload each &block
  #   
  #   @param [::Proc<(Described::Base)=>void>] block
  #     Calls `&block` once for each description, in order.
  #   
  #   @return [Hierarchy] self
  # 
  def each &block
    @storage.reverse_each &block
  end
  
  
  # Re-order a description to be {#current}.
  # 
  # @see Hierarchy#touch
  # @param (see Hierarchy#touch)
  # @return (see Hierarchy#touch)
  # 
  # @raise [NotFoundError]
  #   If `described` is not in the hierarchy.
  # 
  def touch described
    @storage.delete( described ) {
      raise NotFoundError.new described, "not found in description hierarchy",
        described: described,
        descriptions: map( &:to_s )
    }
    
    @storage << described
    
    described
  end
  
  
end # class Array


# /Namespace
# =======================================================================

end # module Hierarchy
end # module Described
end # module NRSER
