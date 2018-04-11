# encoding: UTF-8
# frozen_string_literal: true


# Declarations
# ============================================================================

module NRSER::Char; end


# Namespace Requires
# ============================================================================

require_relative './char/special'
require_relative './char/alpha_numeric_sub'


# Definitions
# =======================================================================

# A place to put things that work with characters.
# 
# **_This is ALL based around UTF-8 by default_**
# 
module NRSER::Char
  
  # Constants
  # ============================================================================
  
  # {Regexp} that matches a control character.
  # 
  # @return [Regexp]
  # 
  CONTROL_RE = /[[:cntrl:]]/
  
  
  # {Regexp} that matches when *all* characters are control characters.
  # 
  # NOTE This will match the empty string.
  # 
  # @return [Regexp]
  # 
  ALL_CONTROL_RE = /\A[[:cntrl:]]*\z/
  
  
  HEX_RE = /\A[0-9a-f]+\z/i
  
  
  # Special Characters
  # ----------------------------------------------------------------------------
  
  # Special character info for the NULL character (zero byte in string).
  # 
  # @return [NRSER::Char::Special]
  # 
  NULL = Special.new \
    char:         "\u0000",
    names:         ['NULL', 'NUL', '<control-0000>'],
    caret:        '^@',
    symbol:       '␀'
  
  
  # Module Methods
  # ============================================================================
  
  # Tests
  # ----------------------------------------------------------------------------
  
  # Test if string is a control character (returns `false` if length > 1).
  # 
  # @param [String] char
  #   String to test.
  # 
  # @return [Boolean]
  #   `true` if `char` is a control character.
  # 
  def self.control? char
    char.length == 1 && CONTROL_RE.match( char )
  end # .control?
  
  
  # Conversions
  # ----------------------------------------------------------------------------
  
  # Convert integer to UTF-8 character (length 1 string).
  # 
  # @param [Integer] int
  #   Integer (decimal/base-10) representation of the character.
  # 
  # @return [String]
  #   UTF-8 character.
  # 
  # @raise
  #   When conversion can't be performed.
  # 
  def self.from_i int
    int.chr Encoding::UTF_8
  end # .from_i
  
  singleton_class.send :alias_method, :from_ord, :from_i
  singleton_class.send :alias_method, :from_dec, :from_i
  
  
  # Convert hex string to UTF-8 character (length 1 string).
  # 
  # @param [String] hex
  #   Hexadecimal (base-16) number represented as a string.
  # 
  # @return [String]
  #   UTF-8 character.
  # 
  # @raise
  #   When conversion can't be performed.
  # 
  def self.from_hex hex
    from_i hex.to_i( 16 )
  end # .from_hex
  
  
  # Convert hex string to UTF-8 character (length 1 string).
  # 
  # @param [String | Integer] source
  #   Hexadecimal (base-16) number represented as a string or a non-negative
  #   integer.
  # 
  # @return [String]
  #   UTF-8 character.
  # 
  # @raise (see .from_hex)
  # 
  def self.from source
    case source
    when HEX_RE
      from_hex source
    when Integer
      from_i source
    else
      raise ArgumentError.new binding.erb <<-END
        Expected hex String like '12AB' or Integer, got <%= source.class %>:
        
            <%= source.pretty_inspect %>
        
      END
    end
  end # .from_hex
  
  
end # module NRSER::Char
