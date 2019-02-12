# frozen_string_literal: true
# encoding: UTF-8

# Namespace
# ========================================================================

module  NRSER
module  Ext
module  String

# Definitions
# =======================================================================

  
# @!group String Functions

# Constants
# =====================================================================

# Regexp used to guess if a string is a JSON-encoded array.
# 
# @return [Regexp]
# 
JSON_ARRAY_RE = /\A\s*\[.*\]\s*\z/m.freeze


# Regexp used to guess if a string is a JSON-encoded object.
# 
# @return [Regexp]
# 
JSON_OBJECT_RE = /\A\s*\{.*\}\s*\z/m.freeze


# Instance Methods
# ============================================================================

# @!group "Looks Like" Instance Methods
# --------------------------------------------------------------------------

# Test if this string looks like it might encode an array in JSON format by
# seeing if it's first non-whitespace character is `[` and last
# non-whitespace character is `]`.
# 
# @param [String] string
#   String to test.
# 
# @return [Boolean]
#   `true` if we think `string` encodes a JSON array.
# 
def looks_like_json_array?
  !!( self =~ Ext::String::JSON_ARRAY_RE )
end # #looks_like_json_array


# Test if this string looks like it might encode an object in JSON format
# (JSON object becomes a {Hash} in Ruby) by seeing if it's first
# non-whitespace character is `{` and last non-whitespace character is `}`.
# 
# @return [Boolean]
#   `true` if we think `string` encodes a JSON object.
# 
def looks_like_json_object?
  !!( self =~ Ext::String::JSON_OBJECT_RE )
end # .looks_like_json_object?


def looks_like_yaml_object?
  # YAML is (now) a super-set of JSON, so anything that looks like a JSON
  # object is kosh
  (
    n_x.looks_like_json_object? ||
    self.lines.all? { |line|
      line.start_with?( '---', '  ', '#' ) || line =~ /[^\ ].*\:/
    }
  )
end

# @!endgroup "Looks Like" Instance Methods # *******************************
  
  
# /Namespace
# ========================================================================

end # mdoule String
end # module Ext
end # module NRSER
