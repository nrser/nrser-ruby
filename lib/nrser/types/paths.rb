# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/core_ext/pathname'

require_relative './is_a'
require_relative './where'
require_relative './combinators'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# Constants
# ----------------------------------------------------------------------------

# Regular expression to match "tilde" user-home-relative paths.
# 
# @return [Regexp]
# 
TILDE_PATH_RE = /\A\~(?:\/|\z)/


# @!group Path Type Factories
# ----------------------------------------------------------------------------

#@!method self.Pathname **options
#   Just a type for instances of {Pathname}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type    :Pathname,
  to_data:  :to_s,
  from_s:   ->( string ) { Pathname.new string } \
do |**options|
  is_a Pathname, **options
end


#@!method self.NonEmptyPathname **options
#   A {.Pathname} that isn't empty. Because not emptiness is often important.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :NonEmptyPathname,
&->( **options ) do
  self.Intersection \
    self.Pathname,
    self.Attributes( to_s: self.NonEmptyString ),
    **options
end # .NonEmptyPathname


# @!method self.Path **options
#   A path is a {.NonEmptyString} or {.NonEmptyPathname}.
#   
#   @param [Hash] options
#     See {Type#initialize}.
#   
#   @return [Type]
# 
def_type        :Path,
&->( **options ) do
  self.Union \
    self.NonEmptyString,
    self.NonEmptyPathname,
    **options
end # #Path


#@!method self.POSIXPathSegment **options
#   A POSIX path segment (directory, file name) - any {.NonEmptyString} that
#   doesn't have `/` in it.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :POSIXPathSegment,
  aliases:      [ :path_segment, :path_seg ],
&->( **options ) do
  self.Intersection \
    self.NonEmptyString,
    self.Respond( to: [:include?, '/'], with: false ),
    **options
end # .POSIXPathSegment


# @!method self.AbsPath **options
#   An absolute {.Path}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :AbsPath,
  # TODO  IDK how I feel about this...
  from_s:       ->( s ) { File.expand_path s },
&->( **options ) do
  self.Intersection \
    self.Path,
    # Weirdly, there is no {File.absolute?}..
    self.Attributes( to_pn: attrs( absolute?: true ) ),
    **options
end


#@!method self.TildePath **options
#   "Home-relative" paths that start with `~`.
#   
#   From my take, these are not relative *and* are not absolute.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :TildePath,
&->( **options ) do
  self.Intersection \
    self.Path,
    self.Attributes( to_s: TILDE_PATH_RE ),
    **options
end # .TildePath


# @!method self.AbsPath **options
#   A relative {.Path}, which is just a {.Path} that's not {.AbsPath} or
#   {.TildePath}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type :RelPath,
&->( **options ) do
  self.Intersection \
    self.Path,
    !self.AbsPath,
    !self.TildePath,
    **options
end


# @method self.DirPath **options
#   A {.Path} that is a directory. Requires checking the file system.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type :DirPath,
&->( **options ) do
  self.Intersection \
    self.Path,
    self.Where( File.method :directory? ),
    **options
end # .DirPath


# @!method self.AbsDirPath **options
#   Absolute {.Path} to a directory (both an {.AbsPath} and an {.DirPath}).
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type :AbsDirPath,
&->( **options ) do
  self.Intersection \
    self.AbsPath,
    self.DirPath,
    **options
end # .AbsDirPath


# @!method self.FilePath **options
#   A {.Path} that is a file (using {File.file?} to test).
# 
# @param name: (see NRSER::Types::Type#initialize)
# 
# @param [Hash] options
#   See {NRSER::Types::Type#initialize}
# 
def_type :FilePath,
&->( **options ) do
  self.Intersection \
    self.Path,
    self.Where( File.method :file? ),
    **options
end # .FilePath


# @!endgroup Path Type Factories # *******************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
