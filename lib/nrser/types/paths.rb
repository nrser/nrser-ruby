# Requirements
# =======================================================================

# stdlib
require 'pathname'

# gems

# package
require_relative './is_a'
require_relative './where'
require_relative './combinators'


# Refinements
# =======================================================================

require 'nrser/refinements'
using NRSER


# Declarations
# =======================================================================

module NRSER; end


# Definitions
# =======================================================================

module NRSER::Types
  
  # A {Pathname} type that provides a `from_s`
  PATHNAME = is_a \
    Pathname,
    name: 'PathnameType',
    from_s: ->(string) { Pathname.new string },
    to_data: :to_s
  
  
  # A type satisfied by a {Pathname} instance that's not empty (meaning it's
  # string representation is not empty).
  NON_EMPTY_PATHNAME = intersection \
    PATHNAME,
    where { |value| value.to_s.length > 0 },
    name: 'NonEmptyPathnameType'
  
  PATH = union non_empty_str, NON_EMPTY_PATHNAME, name: 'Path'
  
  
  # Eigenclass (Singleton Class)
  # ========================================================================
  # 
  class << self
    # @!group Type Factory Functions
    
    def pathname to_data: :to_s, **options
      if options.empty? && to_data == :to_s
        PATHNAME
      else
        is_a \
          Pathname,
          name: 'PathnameType',
          from_s: ->(string) { Pathname.new string },
          to_data: to_data,
          **options
      end
    end
    
    # A path is a non-empty {String} or {Pathname}.
    # 
    # @param **options see NRSER::Types::Type#initialize
    # 
    # @return [NRSER::Types::Type]
    # 
    def path **options
      if options.empty?
        PATH
      else
        union non_empty_str, NON_EMPTY_PATHNAME, **options
      end
    end # #path
    
    
    def path_segment **options
      if options.empty?
        POSIX_PATH_SEGMENT
      else
        intersection  non_empty_str,
                      where { |string| ! string.include?( '/' ) },
                      name: 'POSIXPathSegment'
      end
    end
    
    alias_method :path_seg, :path_segment
    
    
    # An absolute {#path}.
    # 
    # @param **options see NRSER::Types::Type#initialize
    # 
    def abs_path name: 'AbsPath', **options
      intersection \
        path,
        where { |path| path.to_pn.absolute? },
        name: name,
        from_s: ->( s ) { File.expand_path s },
        **options
    end
    
    
    # A {NRSER::Types.path} that is a directory.
    # 
    # @param [Hash] **options
    #   Construction options passed to {NRSER::Types::Type#initialize}.
    # 
    # @return [NRSER::Types::Type]
    # 
    def dir_path name: 'DirPath', **options
      intersection \
        path,
        where { |path| File.directory? path },
        name: name,
        **options
    end # #dir_path
    
    
    # Absolute {.path} to a directory (both an {.abs_path} and an {.dir_path}).
    # 
    # @param [type] name:
    #   @todo Add name param description.
    # 
    # @return [return_type]
    #   @todo Document return value.
    # 
    def abs_dir_path name: 'AbsDirPath', **options
      intersection \
        abs_path,
        dir_path,
        name: name,
        **options
    end # #abs_dir_path
    
    
    
    def file_path name: 'FilePath', **options
      intersection \
        path,
        where { |path| File.file? path },
        name: name,
        **options
    end
    
  end # class << self (Eigenclass)
  
  POSIX_PATH_SEGMENT = path_segment name: 'POSIXPathSegment'
  
end # module NRSER::Types
