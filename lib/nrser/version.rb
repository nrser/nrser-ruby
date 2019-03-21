require 'pathname'

module NRSER
  
  # Absolute, expanded path to the gem's root directory.
  # 
  # Here in `//lib/nrser/version` so that it can be used via
  # 
  #     require 'nrser/version'
  # 
  # without loading the entire module.
  # 
  # @return [Pathname]
  # 
  ROOT = ( Pathname.new( __FILE__ ).dirname / '..' / '..' ).expand_path
  
  
  # String version of the gem.
  # 
  # @return [String]
  # 
  VERSION = '0.4.0.dev'
  
  
  module Version
    
    # @return [Gem::Version]
    #   Parse of {NRSER::VERSION}.
    # 
    def self.gem_version
      Gem::Version.new VERSION
    end # .gem_version
    
    
    # Is this a development version of the gem?
    # 
    # @note
    #   I wrote this working on {Support::CriticalCode}, where I'm thinking to
    #   use it to determine whether or not to suppress (most) all exceptions as
    #   warnings... basically, let them raise in development versions so you 
    #   can find and diagnose problems easily, and suppress them otherwise.
    # 
    # @return [Boolean]
    # 
    def self.dev?
      # Just take the easy way since we know that `dev` is always in the fourth 
      # entry for {NRSER}. If generalizing for other gems or if that at some 
      # point changed this would need to be a bit more complex.
      gem_version.segments[ 3 ] == 'dev'
    end
    
    
    # The `Gem::Version` "release" for {NRSER::VERSION} - everything before
    # any `-<alpha-numeric>` prerelease part (like `-dev`).
    # 
    # @see https://ruby-doc.org/stdlib-2.4.1/libdoc/rubygems/rdoc/Gem/Version.html#method-i-release
    # 
    # @example
    # 
    #   NRSER::VERSION
    #   # => '0.0.21.dev'
    #   
    #   NRSER::Version.release
    #   # => #<Gem::Version "0.0.21">
    # 
    # @return [Gem::Version]
    # 
    def self.release
      gem_version.release
    end # .release
    
    
    # Get a URL to a place in the current version's docs on ruby-docs.org.
    # 
    # @param [String] rel_path
    #   Relative path.
    # 
    # @return [String]
    #   The RubyDocs URL.
    # 
    def self.doc_url rel_path
      File.join(
        "http://www.rubydoc.info/gems/nrser",
        NRSER::Version.release.to_s,
        rel_path
      )
    end # .doc_url
    
  end
end
