# encoding: UTF-8
# frozen_string_literal: true


# Definitions
# =======================================================================

# Lil' structure with useful info and methods for special characters.
# 
class NRSER::Char::Special

  # Attributes
  # ======================================================================
  
  # The character as a length-one string (UTF-8 encoding).
  # 
  # @return [String]
  #     
  attr_reader :char
  
  
  # Zero or more strings names for the character.
  # 
  # @return [Array<String>]
  #     
  attr_reader :names
  
  
  # If the character is a control character, the "caret" (`^X`) style
  # replacement for it.
  # 
  # @example
  #   NRSER::Char::NULL.caret
  #   # => '^@'
  # 
  # @return [nil]
  #   If we don't have a caret replacement for it.
  # 
  # @return [String]
  #   If we have a caret replacement for it.
  #     
  attr_reader :caret
  
  
  # A printable Unicode "control picture" character that can be used as a
  # replacement character for control characters.
  # 
  # @see http://www.unicode.org/charts/PDF/U2400.pdf
  # 
  # The nice things about these is they:
  # 
  # 1.  *Should* allow for replacement without changing the Ruby string
  #     length\*.
  #     
  #     > \* I say *should* because lengths of unicode strings can get funky
  #     > across different platforms due to bytes and code points and glyphs
  #     > and a bunch of other stuff it seems like only about three people
  #     > fully understand.. it often *will* change the *byte length*, and
  #     > who knows how that will go if you start handing it back and forth
  #     > to C or something else.
  #     
  # 2.  Visually represent the replaced character. You know what it was
  #     without having to remember caret or hex representations.
  # 
  # 3.  Have a far lower chance of ambiguity versus {#carat}, {#esc_seq}, etc.
  #     (is a control character or did the string really have a `^X` in it?).
  # 
  # Drawbacks:
  # 
  # 1.  They're all gonna be outside the ASCII range, so if you are for some
  #     reason stuck with something that can't Unicode you're gonna get some
  #     gibberish at best, if not outright breakage.
  # 
  # 2.  They require font support, or you're going to probably get one of those
  #     little box things that we used to see all over the web before browsers
  #     and operating systems managed to get their shit together.
  # 
  # @return [nil]
  #   If we don't have an printable symbol for this character.
  # 
  # @return [String]
  #   Length 1 printable unicode string.
  #     
  attr_reader   :symbol
  alias_method  :picture, :symbol
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `Special`.
  # 
  # @param [String] char
  #   The actual character as a length 1 UTF-8 string.
  # 
  # @param [nil | String] caret
  #   Optional `^X` replacement for control characters, see {#caret} for
  #   details.
  # 
  # @param [Array<#to_s>] names
  #   Optional names this character goes by.
  # 
  # @param [nil | String] symbol
  #   Optional printable unicode character replacement, see {#symbol} for
  #   details.
  # 
  def initialize char:, names: [], caret: nil, symbol: nil
    unless char.is_a?( String ) && char.length == 1
      raise ArgumentError,
        "char must be string of length 1"
    end
    
    @char = char.freeze
    @names = names.map { |n| n.to_s.freeze }.freeze
    @caret = caret.freeze
    @symbol = symbol.freeze
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  # The first of {#names} (if any).
  # 
  # @return [nil]
  #   When {#names} is empty.
  # 
  # @return [String]
  #   When {#names} is not empty.
  # 
  def name
    names[0]
  end
  
  
  # Decimal encoding of the character (with respect to UTF-8).
  # 
  # Equivalent to `.char.ord`.
  # 
  # @return [Fixnum]
  # 
  def dec
    char.ord
  end
  
  alias_method :ord, :dec
  
  
  # @return [String]
  #   Hex string as it would appear in `\uXXXX`.
  def hex
    @hex ||= ("%04X" % char.ord).freeze
  end
  
  
  # @return [Boolean]
  #   `true` if the character is a control character.
  def control?
    @control ||= NRSER::Char.control?( char )
  end
  
  
  def esc_seq
    @esc_seq ||= char.inspect[1..-2].freeze
  end
  
  
  # @return [Boolean]
  #   `true` if the character code-point is in the ASCII range.
  def ascii?
    char.ascii_only?
  end
  
  
  # Replace all occurrences of {#char} in the string.
  # 
  # @param [String] string
  #   String to replace this character in.
  # 
  # @param [Symbol | #to_s] with
  #   What to replace the character with:
  #   
  #   1.  {Symbol} - this method will be called on the instance and the
  #       `#to_s` of the response will be used.
  #       
  #   2.  `#to_s` - string value will be used.
  # 
  # @return [String]
  #   String with {#char} replaced.
  # 
  def replace string, with: :symbol
    with = public_send( with ) if with.is_a?( Symbol )
    string.gsub char, with.to_s
  end
  
end # class NRSER::Char::Special
