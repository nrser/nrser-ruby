# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/core_ext/pathname'

require_relative './is_a'
require_relative './where'
require_relative './combinators'


# Definitions
# =======================================================================

module NRSER::Types
  
  # @!group Type Factory Functions
  
  def_factory :pathname do |to_data: :to_s, **options|
    is_a \
      Pathname,
      from_s: ->( string ) { Pathname.new string },
      to_data: to_data,
      **options
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
  
  
  # A path is a non-empty {String} or {Pathname}.
  # 
  # @param **options see NRSER::Types::Type#initialize
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory :path do |name: 'Path', **options|
    one_of \
      non_empty_str,
      non_empty_pathname,
      name: name,
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
  
  
  # An absolute {#path}.
  # 
  # @param **options see NRSER::Types::Type#initialize
  # 
  def_factory :abs_path do |name: 'AbsPath', **options|
    intersection \
      path,
      # Weirdly, there is no {File.absolute?}..
      attrs( to_pn: attrs( absolute?: true ) ),
      name: name,
      from_s: ->( s ) { File.expand_path s },
      **options
  end
  
  
  # A relative path.
  # 
  # @todo
  #   Quick addition, not sure if it's totally right with regard to tilde
  #   paths and such.
  # 
  def_factory :rel_path do |name: 'RelPath', **options|
    intersection \
      path,
      ~abs_path,
      name: name,
      **options
  end
  
  
  # A {NRSER::Types.path} that is a directory.
  # 
  # @param [Hash] **options
  #   Construction options passed to {NRSER::Types::Type#initialize}.
  # 
  # @return [NRSER::Types::Type]
  # 
  def_factory :dir_path do |name: 'DirPath', **options|
    intersection \
      path,
      # TODO  How to change this from {.where}?
      where { |path| File.directory? path },
      name: name,
      **options
  end # #dir_path
  
  
  # Absolute {.path} to a directory (both an {.abs_path} and an {.dir_path}).
  # 
  # @param name: (see NRSER::Types::Type#initialize)
  # 
  # @param **options
  #   See {NRSER::Types::Type#initialize}
  # 
  def_factory :abs_dir_path do |name: 'AbsDirPath', **options|
    intersection \
      abs_path,
      dir_path,
      name: name,
      **options
  end # .abs_dir_path
  
  
  # A {.path} that is a file (using {File.file?} to test).
  # 
  # @param name: (see NRSER::Types::Type#initialize)
  # 
  # @param **options
  #   See {NRSER::Types::Type#initialize}
  # 
  def_factory :file_path do |name: 'FilePath', **options|
    intersection \
      path,
      # TODO  How to change this from {.where}?
      where { |path| File.file? path },
      name: name,
      **options
  end
  
end # module NRSER::Types
