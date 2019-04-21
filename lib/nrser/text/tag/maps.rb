# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Project / Package ###

require_relative '../tag'


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Tag


# Definitions
# =======================================================================

class Map < ::Hash

  # Mixins
  # ==========================================================================
  
  include Tag
  
  
  # Construction
  # ==========================================================================
  
  # Instantiate a new {Map}.
  # 
  def initialize **objects
    super()
    replace objects
    # freeze
  end # #initialize
  
end


class Values < Map; end


# /Namespace
# =======================================================================

end # module  Tag
end # module  Text
end # module  NRSER
