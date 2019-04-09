# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# Abstract base class for a very simple, target-agnostic tagging system for
# structured text.
#
module Tag
  def render_name
    name = self.class.name
    
    if name.start_with?( Tag.name + '::' )
      name.sub! Tag.name + '::', ''
    end
    
    name.underscore.gsub '/', '_'
  end
end # module Tag


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
