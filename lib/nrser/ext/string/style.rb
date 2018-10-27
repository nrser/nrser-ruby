# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require 'nrser/char/alpha_numeric_sub'


# Namespace
# ========================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

module String
  
  # Instance Methods
  # ========================================================================

  # @!group Unicode Stylization Instance Methods
  # --------------------------------------------------------------------------
  
  # Calls {NRSER::Char::AlphaNumericSub.unicode_math_italic.sub} on `self`.
  def u_italic
    NRSER::Char::AlphaNumericSub.unicode_math_italic.sub self
  end
  
  
  # Calls {NRSER::Char::AlphaNumericSub.unicode_math_bold.sub} on `self`.
  def u_bold
    NRSER::Char::AlphaNumericSub.unicode_math_bold.sub self
  end
  
  
  # Calls {NRSER::Char::AlphaNumericSub.unicode_math_bold_italic.sub on `self`.
  def u_bold_italic
    NRSER::Char::AlphaNumericSub.unicode_math_bold_italic.sub self
  end
  
  
  # Calls {NRSER::Char::AlphaNumericSub.unicode_math_monospace.sub} on `self`.
  def u_mono
    NRSER::Char::AlphaNumericSub.unicode_math_monospace.sub self
  end

  # @!endgroup Unicode Stylization Instance Methods # ************************

end # module String


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
