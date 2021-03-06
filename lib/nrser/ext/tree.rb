# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/functions/tree'

require_relative './tree/bury'


# Namespace
# ========================================================================

module NRSER
module Ext


# Instance methods that are refined in to the Ruby built-ins that we consider
# trees: {Array}, {Hash} and {OpenStruct}.
# 
module Tree
  
  # Sends `self` to {NRSER.leaves}.
  def leaves
    NRSER.leaves self
  end # #leaves
  
  
  # Calls {NRSER.map_leaves} on `self` with `&block`.
  # 
  def map_leaves &block
    NRSER.map_leaves self, &block
  end
  
  
  # Sends `self` and the optional `block` to {NRSER.each_branch}.
  # 
  def each_branch &block
    NRSER.each_branch self, &block
  end
  
  
  # Calls {NRSER.map_branches} on `self` with `&block`.
  # 
  def map_branches &block
    NRSER.map_branches self, &block
  end # #map_branches
  
  
  # Calls {NRSER.map_tree} on `self` with `&block`.
  # 
  def map_tree **options, &block
    NRSER.map_tree self, **options, &block
  end

end # module Tree


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
