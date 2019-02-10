# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './list'
require_relative './kwds'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Format


# Definitions
# =======================================================================

# A {List} that in specific represents arguments to a method.
# 
class Args < List
  def to_desc max = nil
    return '()' if empty?
    
    if last.is_a? ::Hash
      [
        List.new( self[0..-2] ).to_desc,
        Kwds[ last ].to_desc,
      ].
        # reject( &:empty? ). TODO  Why was this here?!
        join( ", " )
    else
      super
    end
  end
end


# /Namespace
# =======================================================================

end # module  Format
end # module  RSpec
end # module  Described
end # module  NRSER
