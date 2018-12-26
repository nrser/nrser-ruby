# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require_relative './name'
require_relative './var'


# Refinements
# =======================================================================

require 'nrser/refinements/regexps'
using NRSER::Regexps


# Namespace
# =======================================================================

module  NRSER
module  Meta
module  Names


# Definitions
# =======================================================================

# Abstract base class for variable names, defining the interface.
# 
# @abstract
# 
class Var < Name
 
  # @note
  #   Instance variables names *can* start with or be all capital letters,
  #   and at least `attr_accessor` seems to work fine with it, which makes sense
  #   since method names can be caps too.
  #   
  #   Check this shit...
  #   
  #   ```Ruby
  #   class BadAttr
  #     attr_accessor :BAD
  #   
  #     def initialize bad
  #       @BAD = bad
  #     end
  #   end
  #   
  #   bad = BadAttr.new 'bad...'
  #   bad.BAD
  #   #=> "bad..."
  #   
  #   bad.BAD = 'worse!'
  #   bad.BAD
  #   #=> "worse!"
  #   ```
  #   
  #   Ok, calm down. I don't want to lose my developer's license, so, please,
  #   everyone repeat after me: "Just because you *can*, doesn't mean you..."
  #   
  class Instance < Var
    pattern /\A@[A-Za-z_][A-Za-z0-9_]*\z/
  end
  
  
  class Local < Var
    pattern /\A[a-z_][A-Za-z0-9_]*\z/
  end
  
  
  class Global < Var
    
    # Constants
    # ========================================================================
    
    # Pattern for the weird-ass CLI flag-style global variables, like `$-d`
    # (A.K.A. `$DEBUG`, the "debugging" status, populated by the `-d` CLI
    # switch).
    #
    # All the pre-defined ones listed in the [Globals][] docs all seem to
    # correspond to CLI switches. Some are read-only; most are writable.
    #
    # In addition to the built-in "flag" globals, users appear to be able to set
    # their own following the same format.
    #
    # [Globals]: https://docs.ruby-lang.org/en/2.3.0/globals_rdoc.html
    #
    # @return [::Regexp]
    #
    FLAG_REGEXP = /\A\$\-[A-Za-z0-9]\z/
    
    # Pattern for `$0`, `$1`, .., `$9`.
    # 
    # @return [::Regexp]
    # 
    NUMERIC_REGEXP = /\A\$[0-9]\z/
    
    # Pattern for the pre-defined globals (and special `$` locals like `$~`)
    # whose names are '$' followed by one of many symbols.
    # 
    # It doesn't seem possible for users to define any additional variables of
    # this format.
    # 
    # @return [::Regexp]
    # 
    SYMBOL_REGEXP = \
      Regexp.new "\\A\\$[#{ ::Regexp.escape %{!@&`'+~=/\\,;.<>_*$?:"} }]\\z"
    
    
    # The common user format, which is also used for some pre-defined globals
    # and textual aliases for many of the {SYMBOL_REGEXP} format.
    #
    # @note
    #   "$_" matches this, though it's really a "symbol" format. It just seems
    #   like it will make things messy to carve out that one case. It doesn't
    #   make any difference in {.pattern} and it's taken account of in
    #   {#common?}, but something to be aware of if you're using this {::Regexp}
    #   for other purposes.
    #
    # @return [::Regexp]
    #
    COMMON_REGEXP = /\A\$[A-Za-z_][A-Za-z0-9]*\z/
    
    
    # Config
    # ========================================================================
    
    pattern re.or(
      COMMON_REGEXP,
      NUMERIC_REGEXP,
      SYMBOL_REGEXP,
      FLAG_REGEXP,
      full: true
    )
    
    
    # Instance Methods
    # ========================================================================
    
    # @!group What sort of "global"? Instance Methods
    # ------------------------------------------------------------------------
    
    def common?
      # Need to make sure we *don't* match {SYMBOL_REGEXP}, since "$_" will
      # match {COMMON_REGEXP}.
      !!( SYMBOL_REGEXP !~ self && COMMON_REGEXP =~ self )
    end
    
    # @!endgroup What sort of "global"? Instance Methods # *******************
    
    
  end # class Global

end # class Var

# /Namespace
# =======================================================================

end # module Names
end # module Meta
end # module NRSER
