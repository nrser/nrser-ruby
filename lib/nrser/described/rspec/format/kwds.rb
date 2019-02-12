# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './list'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Format


# Definitions
# =======================================================================

class Kwds < ::Hash
  def to_desc max = nil
    return '' if empty?
    
    max = [16, ( 64 / self.count )].max if max.nil?
    
    map { |key, value|
      if key.is_a? Symbol
        "#{ key }: #{ Format.short_s value, max }"
      else
        [ Format.short_s( key, max ),
          Format.short_s( value, max ),
        ].join ' => '
      end
    }.join( ", " )
  end
end


# /Namespace
# =======================================================================

end # module  Format
end # module  RSpec
end # module  Described
end # module  NRSER
