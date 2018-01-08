# frozen_string_literal: true

##
# Functional methods that try to tell what format a string that
# is presumed to encode structural data is encoded in.
##


# Definitions
# =======================================================================

module NRSER
  
  # @!group String Functions
  
  # Constants
  # =====================================================================
  
  # Regexp used to guess if a string is a JSON-encoded array.
  # 
  # @return [Regexp]
  # 
  JSON_ARRAY_RE = /\A\s*\[.*\]\s*\z/m.freeze
  
  
  # Functions
  # ============================================================================
  

  # Test if a string looks like it might encode an array in JSON format by
  # seeing if it's first non-whitespace character is `[` and last
  # non-whitespace character is `]`.
  # 
  # @param [String] string
  #   String to test.
  # 
  # @return [Boolean]
  #   `true` if we think `string` encodes a JSON array.
  # 
  def self.looks_like_json_array? string
    !!( string =~ JSON_ARRAY_RE )
  end # #looks_like_json_array
  
end # module NRSER
