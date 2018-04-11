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
  
  
  # Regexp used to guess if a string is a JSON-encoded object.
  # 
  # @return [Regexp]
  # 
  JSON_OBJECT_RE = /\A\s*\{.*\}\s*\z/m.freeze
  
  
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
  
  
  # Test if a string looks like it might encode an object in JSON format
  # (JSON object becomes a {Hash} in Ruby) by seeing if it's first
  # non-whitespace character is `{` and last non-whitespace character is `}`.
  # 
  # @param [String] string
  #   String to test.
  # 
  # @return [Boolean]
  #   `true` if we think `string` encodes a JSON object.
  # 
  def self.looks_like_json_object? string
    !!( string =~ JSON_OBJECT_RE )
  end # .looks_like_json_object?
  
  
  def self.looks_like_yaml_object? string
    # YAML is (now) a super-set of JSON, so anything that looks like a JSON
    # object is kosh
    looks_like_json_object?( string ) || string.lines.all? { |line|
      line.start_with?( '---', '  ', '#' ) || line =~ /[^\ ].*\:/
    }
  end
  
  
end # module NRSER
