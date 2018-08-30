# frozen_string_literal: true
# encoding: UTF-8

# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

require 'pathname'

# Project / Package
# ------------------------------------------------------------------------

# Need {ValueError}
require 'nrser/errors/value_error'


# Definitions
# ========================================================================

class Pathname

  # Is `other` a subpath of `self`?
  # 
  # Which - it turns out - is a bit of a ricky question! Who knew?!
  # 
  # Maybe that's why it's not in the stand' lib.
  # 
  # Here's how we gonna go:
  # 
  # 1.  Raise a {NRSER::ValueError} unless `self` is a {#directory?} and is
  #     {#absolute?}.
  #     
  #     I don't think it make any sense to ask about subpaths of something that
  #     is not a directory, and things just get too messy unless it's absolute
  #     since we need to expand `other` to make sure it doesn't dot-dot-dig 
  #     it's way outta there.
  # 
  # 2.  
  # 
  # @param [Boolean] strict
  #   Decides behavior when `other` expands to the same directory as `self`:
  #   
  #   1.  When `strict: false` (the default) a directory **is** considered a 
  #       subpath of itself.
  #       
  #   2.  When `strict: true`, a directory **is not** considered a subpath of
  #       itself.
  # 
  # @return [Boolean]
  #   `true` if `other` is a path inside `self`.
  #   
  #   See the `strict` parameter for behavior when `other` expands to `self`.
  # 
  # @raise [NRSER::ValueError]
  #   If `self` is not a {#directory?}.
  # 
  # @raise [NRSER::ValueError]
  #   If `self` is not {#absolute?}.
  # 
  def subpath? other, root: nil, strict: false
    unless directory?
      raise NRSER::ValueError.new \
        "Receiver {Pathname}", self, "must be a {#directory} in order to test",
        "for subpaths",
        value: self
    end

    unless absolute?
      raise NRSER::ValueError.new \
        "Receiver {Pathname}", self, "must be {#absolute?} in order to test",
        "for subpaths",
        value: self
    end

    abs_other = other.to_pn.expand_path root

    # Deal with easy case first, when they're the same dir
    return !strict if self == abs_other

    # Ok, now see if they prefix match
    abs_other.start_with? self
  end # #subpath?
  
end # class Pathname
