# encoding: UTF-8
# frozen_string_literal: true
##
# Functional methods to stylize a string through substitution
##

module NRSER
  
  # @!group String Functions
  # ============================================================================
  
  # Proxies to {NRSER::Char::AlphaNumericSub#sub} on
  # {NRSER::Char::AlphaNumericSub.unicode_math_italic} to convert regular
  # UTF-8/ASCII `a-zA-Z` characters to the "Unicode Math Italic" set.
  # 
  # @param [String] string
  #   Input.
  # 
  # @return [String]
  #   Output. Probably won't be `#ascii_only?`.
  # 
  def self.u_italic string
    NRSER::Char::AlphaNumericSub.unicode_math_italic.sub string
  end
  
  
  # Proxies to {NRSER::Char::AlphaNumericSub#sub} on
  # {NRSER::Char::AlphaNumericSub.unicode_math_italic} to convert regular
  # UTF-8/ASCII `a-zA-Z` characters to the "Unicode Math Italic" set.
  # 
  # @param [String] string
  #   Input.
  # 
  # @return [String]
  #   Output. Probably won't be `#ascii_only?`.
  # 
  def self.u_bold string
    NRSER::Char::AlphaNumericSub.unicode_math_bold.sub string
  end
  
  
  # Proxies to {NRSER::Char::AlphaNumericSub#sub} on
  # {NRSER::Char::AlphaNumericSub.unicode_math_bold_italic} to convert regular
  # UTF-8/ASCII `a-zA-Z` characters to the "Unicode Math Bold Italic" set.
  # 
  # @param [String] string
  #   Input.
  # 
  # @return [String]
  #   Output. Probably won't be `#ascii_only?`.
  # 
  def self.u_bold_italic string
    NRSER::Char::AlphaNumericSub.unicode_math_bold_italic.sub string
  end
  
  
  # Proxies to {NRSER::Char::AlphaNumericSub#sub} on
  # {NRSER::Char::AlphaNumericSub.unicode_math_monospace} to convert regular
  # UTF-8/ASCII `a-zA-Z` characters to the "Unicode Math Monospace" set.
  # 
  # @param [String] string
  #   Input.
  # 
  # @return [String]
  #   Output. Probably won't be `#ascii_only?`.
  # 
  def self.u_mono string
    NRSER::Char::AlphaNumericSub.unicode_math_monospace.sub string
  end
  
end # module NRSER
