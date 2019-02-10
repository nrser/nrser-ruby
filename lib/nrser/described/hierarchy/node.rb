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
class Node
  
  # Mixins
  # ========================================================================
  
  include Hierarchy
  
  
  # The parent node, if any.
  # 
  # @return [Node?]
  #     
  attr_reader :parent
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new {Hierarchy::Array}.
  # 
  def initialize described, parent: nil
    @described = described
    @parent = parent
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  # Add a {Described::Base} to the hierarchy. It will become {#current} and 
  # first in {#each}.
  # 
  # @see Hierarchy#add
  # 
  # @param [Described::Base] described
  #   {Described::Base} instance to add.
  # 
  # @return [Node]
  #   The new {Hierarchy::Node} around `described`, pointing to this instance 
  #   as it's {#parent}.
  # 
  def add described
    self.class.new described, parent: self
  end
  
  
  def current
    @described
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
    block.call @described
    @parent.each( &block ) if @parent
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
    described
  end
  
  
end # class Node


# /Namespace
# =======================================================================

end # module Hierarchy
end # module Described
end # module NRSER
