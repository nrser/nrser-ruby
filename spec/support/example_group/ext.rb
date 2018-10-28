# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  Support
module  ExampleGroup

# Definitions
# =======================================================================

def EXT method_name, *description, **metadata, &body
  INSTANCE_METHOD \
    method_name, 
    *description,
    **metadata \
  do
    subject do
      
    end
  end
end

# /Namespace
# =======================================================================

end # module ExampleGroup
end # module Support
