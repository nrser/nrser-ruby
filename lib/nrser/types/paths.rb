# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Using {NRSER::Ext::Pathname.absolute?}
require 'nrser/ext/pathname'

require 'nrser/functions/path/normalized'

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


# @!method self.AbsolutePath **options
#   An absolute {.Path}.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :AbsolutePath,
  aliases:      [ :AbsPath, :abs_path ],
  # TODO  IDK how I feel about this...
  # from_s:       ->( s ) { File.expand_path s },
&->( **options ) do
  self.Intersection \
    self.Path,
    # Weirdly, there is no {File.absolute?}...
    self.Where( NRSER::Ext::Pathname.method :absolute? ),
    self.Attributes( to_pn: attrs( absolute?: true ) ),
    **options
end # .AbsolutePath


#@!method self.HomePath **options
#   A path that starts with `~`, meaning it's relative to a user's home 
#   directory (to Ruby, see note below).
# 
#   > ### Note: How Bash and Ruby Think Differently About Home Paths ###
#   > 
#   > #### Ruby Always Tries to Go Home ####
#   > 
#   > From my understanding and fiddling around Ruby considers *any* path that
#   > starts with `~` a "home path" for the purpose of expanding, such as in
#   > {::File.expand_path} and {::Pathname#expand_path}.
#   > 
#   > You can see this clearly in the [rb_file_expand_path_internal][] C
#   > function, which is where those expand methods end up.
#   > 
#   > [rb_file_expand_path_internal]: https://github.com/ruby/ruby/blob/61bef8612afae25b912627e69699ddbef81adf93/file.c#L3486
#   > 
#   > #### Bash  ####
#   > 
#   > However
#   > 
#   > However - Bash 4's `cd` - on MacOSX, at least - treats `~some_user` as 
#   > being a home directory *only if* `some_user` exists... and you may have
#   > a file or directory in the working dir named `~some_user` that it will 
#   > correctly fall back on if `some_user` does not exist.
#   > 
#   > Paths are complicated, man.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :HomePath,
&->( **options ) do
  self.Intersection \
    self.Path,
    self.Respond( to: [ :start_with?, '~' ], with: self.True ),
    **options
end # .HomePath


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


#@!method self.NormalizedPath **options
#   @todo Document NormalizedPath type factory.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :NormalizedPath,
  aliases:      [ :NormPath, :norm_path ],
&->( **options ) do
  self.Intersection \
    self.Path,
    self.Where( NRSER.method :normalized_path? ),
    **options
end # .NormalizedPath



# @!endgroup Path Type Factories # *******************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
