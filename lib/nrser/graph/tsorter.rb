# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Topological sorting
require 'tsort'


# Namespace
# ========================================================================

module  NRSER
module  Graph


# Definitions
# =======================================================================

# Topologically sorts an {Enumerable} by a user-provided `child_node` block.
# 
class TSorter
  include TSort
  
  def initialize entries, &each_child
    @entries = entries
    @each_child = each_child
  end
  
  def tsort_each_node &block
    @entries.each &block
  end
  
  def tsort_each_child node, &block
    @each_child.call node, &block
  end
end # class TSorter


# /Namespace
# ========================================================================

end # module Graph
end # module NRSER
