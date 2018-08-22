require 'pathname'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/string/inflections'
require 'nrser/sys/env'

# Extension methods for {String}
# 
class String

  # The method I alias as unary `~`, with a full-name so I can find it and
  # such, I guess.
  # 
  # It's a string formatter. Right now, it just calls {#squish}, but I would
  # like to make it a bit smarter soon so it can be used on 
  # paragraph-structured text too.
  # 
  # It's meant to be used with the `%{}` string quote form, because that allows
  # multi-line strings, but nothing stopping it from being used elsewhere too.
  # 
  # @example
  # 
  #     ~%{
  #       Hey there, here's some "stuff",
  #       and here's some MORE!
  #     }
  #     # => "Hey there, here's some \"stuff\", and here's some MORE!"
  # 
  # @return [String]
  # 
  def squiggle
    squish
  end

  alias_method :~@, :squiggle

  
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
  # @param [String | Regexp] prefixes
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


  # @!group Inflection Instance Methods
  # ==========================================================================
  
  # Attempt to convert `self` into an ENV var name.
  # 
  # @see NRSER::Sys::Env.varize
  # 
  # @return (see NRSER::Sys::Env.varize)
  # 
  def env_varize
    NRSER::Sys::Env.varize self
  end

  # @!endgroup Inflection Instance Methods # *********************************
  
end # class String
