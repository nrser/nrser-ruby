module NRSER
  VERSION = "0.0.21.dev"
  
  module Version
    
    # @return [Gem::Version]
    #   Parse of {NRSER::VERSION}.
    # 
    def self.gem_version
      Gem::Version.new VERSION
    end # .gem_version
    
    
    # The [Gem::Version][] [release][Gem::Version#release] for {NRSER::VERSION}
    # - everything before any `-<alpha-numeric>` prerelease part (like `-dev`).
    # 
    # [Gem::Version]: https://ruby-doc.org/stdlib-2.4.1/libdoc/rubygems/rdoc/Gem/Version.html
    # [Gem::Version#release]: https://ruby-doc.org/stdlib-2.4.1/libdoc/rubygems/rdoc/Gem/Version.html#method-i-release
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
    
  end
end
