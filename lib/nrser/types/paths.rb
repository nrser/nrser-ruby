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

def_type    :Pathname,
  to_data:  :to_s,
  from_s:   ->( string ) { Pathname.new string } \
do |**options|
  is_a Pathname, **options
end


# A type satisfied by a {Pathname} instance that's not empty (meaning it's
# string representation is not empty).
def_factory :non_empty_pathname do |name: 'NonEmptyPathname', **options|
  all_of \
    pathname,
    attrs( to_s: non_empty_str ),
    name: name,
    **options
end


# @!method .Path **options
#   A path is a non-empty {String} or {Pathname}.
#   
#   @param [Hash] options
#     See {Type#initialize}.
#   
#   @return [Type]
# 
def_type :Path do |**options|
  one_of \
    non_empty_str,
    non_empty_pathname,
    **options
end # #path


def_factory :posix_path_segment,
            aliases: [:path_segment, :path_seg] \
do |name: 'POSIXPathSegment', **options|
  all_of \
    non_empty_str,
    respond( to: [:include?, '/'], with: false ),
    name: name,
    **options
end


# @!method .AbsPath **options
#   An absolute {.path}.
#   
#   @param [Hash] options
#     See {Type#initialize}.
#   
#   @return [Type]
#   
def_type :AbsPath do |**options|
  intersection \
    self.Path,
    # Weirdly, there is no {File.absolute?}..
    attrs( to_pn: attrs( absolute?: true ) ),
    from_s: ->( s ) { File.expand_path s },
    **options
end


# A relative path.
# 
# @todo
#   Quick addition, not sure if it's totally right with regard to tilde
#   paths and such.
# 
def_type :RelPath do |**options|
  intersection \
    path,
    ~abs_path,
    **options
end


# A {NRSER::Types.path} that is a directory.
# 
# @param [Hash] options
#   Construction options passed to {NRSER::Types::Type#initialize}.
# 
# @return [NRSER::Types::Type]
# 
def_factory :dir_path do |name: 'DirPath', **options|
  intersection \
    path,
    where( File.method :directory? ),
    name: name,
    **options
end # #dir_path


# Absolute {.path} to a directory (both an {.abs_path} and an {.dir_path}).
# 
# @param name: (see NRSER::Types::Type#initialize)
# 
# @param [Hash] options
#   See {NRSER::Types::Type#initialize}
# 
def_factory :abs_dir_path do |name: 'AbsDirPath', **options|
  intersection \
    abs_path,
    dir_path,
    name: name,
    **options
end # .abs_dir_path


# @!method self.FilePath **options
# 
# A {.path} that is a file (using {File.file?} to test).
# 
# @param name: (see NRSER::Types::Type#initialize)
# 
# @param [Hash] options
#   See {NRSER::Types::Type#initialize}
# 
def_type :FilePath do |**options|
  intersection \
    path,
    where( File.method :file? ),
    **options
end


def_type :TildePath do |**options|
  intersection \
    path,
    attrs( to_s: TILDE_PATH_RE ),
    **options
end

# @!endgroup Path Type Factories # *******************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
