require 'pathname'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inflections'

# Extension methods for {String}
# 
class String
  
  def unblock
    NRSER.unblock self
  end
  
  
  def dedent
    NRSER.dedent self
  end
  
  
  def indent *args
    NRSER.indent self, *args
  end
  
  
  def to_const
    safe_constantize
  end
  
  
  def to_const!
    constantize
  end
  
  
  # @return [Pathname]
  #   Convert self into a {Pathname}
  # 
  def to_pn
    Pathname.new self
  end
  
  
  def whitespace?
    NRSER.whitespace? self
  end
  
  
  # Calls {NRSER.ellipsis} on `self`.
  def ellipsis *args
    NRSER.ellipsis self, *args
  end
  
  
  # Calls {NRSER.words} on `self`
  def words *args, &block
    NRSER::words self, *args, &block
  end
  
  
  # Alias the stdlib {#start_with?} 'cause we'll need to use it when
  # redefining the method below.
  # 
  alias_method :stdlib_start_with?, :start_with?
  
  
  # Augment {#start_with?} to accept {Regexp} prefixes.
  # 
  # I guess I always *just felt* like this should work... so now it does
  # (kinda, at least).
  # 
  # Everything should work the exact same for {String} prefixes.
  # 
  # Use {Regexp} ones at your own pleasure and peril.
  # 
  # @param [String | Regexp] *prefixes
  #   Strings behave as usual per the standard lib.
  #   
  #   Regexp sources are used to create a new Regexp with `\A` at the start -
  #   unless their source already starts with `\A` or `^` - and those Regexp
  #   are tested against the string.
  #   
  #   Regexp options are also copied over if a new Regexp is created. I can
  #   def imagine things getting weird with some exotic regular expression
  #   or another, but this feature is really indented for very simple patterns,
  #   for which it should suffice.
  #   
  # @return [Boolean]
  #   `true` if `self` starts with *any* of the `prefixes`.
  # 
  def start_with? *prefixes
    unless prefixes.any? { |x| Regexp === x }
      return stdlib_start_with? *prefixes
    end
  
    prefixes.any? { |prefix|
      case prefix
      when Regexp
        unless prefix.source.start_with? '\A', '^'
          prefix = Regexp.new( "\\A#{ prefix.source }", prefix.options )
        end
        
        prefix =~ self
      else
        stdlib_start_with? prefix
      end
    }
  end
  
  
  # @!group Unicode Stylization
  # ==========================================================================
  
  # Calls {NRSER.u_italic} on `self`
  def u_italic
    NRSER.u_italic self
  end
  
  
  # Calls {NRSER.u_bold} on `self`
  def u_bold
    NRSER.u_bold self
  end
  
  
  # Calls {NRSER.u_bold_italic} on `self`
  def u_bold_italic
    NRSER.u_bold_italic self
  end
  
  
  # Calls {NRSER.u_mono} on `self`
  def u_mono
    NRSER.u_mono self
  end
  
  # @!endgroup Unicode Stylization
  
end # class String
