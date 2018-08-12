# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------
require 'pathname'

# Project / Package
# -----------------------------------------------------------------------
require 'nrser/errors/type_error'


# Namespace
# =======================================================================

module  NRSER


# Definitions
# =======================================================================

# Test if a path is what I'm calling "normalized" - generally free of any 
# `.`, `..` or empty segments, with specific exceptions for `'/'` and `'.'`.
# 
# @param [String | Pathname] path
#   Path to test.
# 
# @return [Boolean]
#   `true` if we consider the path "normalized".
# 
# @raise [NRSER::TypeError]
#   If `path` is not a {String} or {Pathname}.
# 
def self.normalized_path? path
  string = case path
  when String
    path
  when Pathname
    path.to_s
  else
    raise NRSER::TypeError.new \
      "path must be String or Pathname, found", path,
      expected: [ String, Pathname ],
      found: path
  end

  # Examine each segment

  # NOTE  The `-1` is *extremely* important - it stops suppression of empty
  #       entries in the result, and we need them!
  segments = string.split File::SEPARATOR, -1 

  segments.
    # We need the indexes, since the first and last segments can be empty,
    # corresponding to `/...` and `.../` paths, respectively.
    each_with_index.
    # See if they all meet the requirements
    all? { |segment, index|
      (
        segment != '.' || # Can't have any `.../x/./y/...` business
        index == 0 # But we can have `./x/y/` and such
      ) &&
      segment != '..' && # Can't have any `.../x/../y/...` crap either
      (
        # and, finally, the segment can't be empty
        segment != '' ||
        # unless it's the first (`/x/...` case)
        index == 0 ||
        # or the last segment (`.../z/` case)
        index == segments.length - 1
      )
    }
end # .normalized_path?

singleton_class.send :alias_method, :norm_path?, :normalized_path?


# /Namespace
# =======================================================================

end # module NRSER
