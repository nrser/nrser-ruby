##
# Functional methods that try to tell what format a string that
# is presumed to encode structural data is encoded in.
##

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Definitions
# =======================================================================

module NRSER
  
  # Constants
  # =====================================================================
  
  JSON_ARRAY_RE = /\A\s*\[.*\]\s*\z/m
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    
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
    def looks_like_json_array? string
      !!( string =~ JSON_ARRAY_RE )
    end # #looks_like_json_array
    
  end # class << self (Eigenclass)
  
end # module NRSER

