# encoding: UTF-8
# frozen_string_literal: true


# Requirements
# ========================================================================

# Stdlib
# ------------------------------------------------------------------------

# Need {Set}
require 'set'

# Deps
# ----------------------------------------------------------------------------

# Need {String#underscore}
require 'active_support/core_ext/string/inflections'


# Namespace
# =======================================================================

module  NRSER
module  Sys


# Definitions
# =======================================================================

# Tools for dealing with the system (POSIX-like) environment.
module Env

  # Constants
  # ========================================================================
  
  # Common and/or important ENV var names that we don't really want to end
  # up auto-generating.
  # 
  # @see http://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap08.html
  # @see https://archive.is/fmBRH
  # 
  # @return [Set<String>]
  # 
  COMMON_EXPORT_NAMES = Set[
    "ARFLAGS",
    "CC",
    "CDPATH",
    "CFLAGS",
    "CHARSET",
    "COLUMNS",
    "DATEMSK",
    "DEAD",
    "EDITOR",
    "ENV",
    "EXINIT",
    "FC",
    "FCEDIT",
    "FFLAGS",
    "GET",
    "GFLAGS",
    "HISTFILE",
    "HISTORY",
    "HISTSIZE",
    "HOME",
    "IFS",
    "LANG",
    "LC_ALL",
    "LC_COLLATE",
    "LC_CTYPE",
    "LC_MESSAGES",
    "LC_MONETARY",
    "LC_NUMERIC",
    "LC_TIME",
    "LDFLAGS",
    "LEX",
    "LFLAGS",
    "LINENO",
    "LINES",
    "LISTER",
    "LOGNAME",
    "LPDEST",
    "MAIL",
    "MAILCHECK",
    "MAILER",
    "MAILPATH",
    "MAILRC",
    "MAKEFLAGS",
    "MAKESHELL",
    "MANPATH",
    "MBOX",
    "MORE",
    "MSGVERB",
    "NLSPATH",
    "NPROC",
    "OLDPWD",
    "OPTARG",
    "OPTERR",
    "OPTIND",
    "PAGER",
    "PATH",
    "PPID",
    "PRINTER",
    "PROCLANG",
    "PROJECTDIR",
    "PS1",
    "PS2",
    "PS3",
    "PS4",
    "PWD",
    "RANDOM",
    "SECONDS",
    "SHELL",
    "TERM",
    "TERMCAP",
    "TERMINFO",
    "TMPDIR",
    "TZ",
    "USER",
    "VISUAL",
    "YACC",
    "YFLAGS",
  ].freeze


  # Regular expression mathcing strict and portable ENV var name rules:
  # only `A-Z`, `0-9` and `_`; can not start with digit.
  # 
  # @return [RegExp]
  # 
  VAR_NAME_RE = /\A[A-Z_][A-Z0-9_]+\z/


  # Class Methods
  # ========================================================================

  # Is ENV var name?
  # 
  # Must be {String} and match {VAR_NAME_RE}.
  # 
  # @param [Object] name
  #   The name. No chance of `true` unless it's a {String}.
  # 
  # @return [Boolean]
  #   `true` if it passes our mustard.
  # 
  def self.var_name? name
    String === name && VAR_NAME_RE =~ name
  end # .var_name?


  # Attempt to munge any string into a decent-looking and legal ENV var name.
  # 
  # We follow a strict, very portable (should be find in `sh`) guideline:
  # 
  # > Environment variable names [...] consist solely of uppercase letters, 
  # > digits, and the '_' (underscore) [...] and do not begin with a digit.
  # 
  # @see http://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap08.html
  # @see https://archive.is/fmBRH
  # 
  # @param [String] string
  #   Take a guess.
  # 
  # @return [nil]
  #   If we didn't end up with a legal ENV var name.
  # 
  # @return [String]
  #   If we were able to munge a legal ENV var name.
  # 
  def self.varize string, prohibit_common_exports: false
    candidate = string.
      # 1.  Use {ActiveSupport}'s {String#underscore} to produce a nicely
      #     underscore-separated name for common strings like class names.
      underscore.
      # 2.  Convert lower-case letters to upper case.
      upcase.
      # 3.  Smush all contiguous runs of anything not `A-Z0-9` into a `_`.
      gsub( /[^A-Z0-9]+/, '_' ).
      # 4.  Bite off any leading digits.
      sub( /\A\d+/, '' ).
      # 5.  Chomp off any trailing `_`. Just for good looks :)
      chomp( '_' )
    
    # Return `nil` if we didn't get a legal ENV var name
    return nil unless var_name?( candidate )

    # If `prohibit_common_exports` is `true` and the name we made is in 
    # that list then return `nil`.
    if prohibit_common_exports && COMMON_EXPORT_NAMES.include?( candidate )
      return nil
    end

    # If we got here, we're good!
    return candidate
  end # .varize

end # module Env


# /Namespace
# =======================================================================

end # module Sys
end # module NRSER
