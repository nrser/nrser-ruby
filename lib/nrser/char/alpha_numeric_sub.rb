# encoding: UTF-8
# frozen_string_literal: true


# Refinements
# =======================================================================

require 'nrser/refinements/types'
using NRSER::Types


# Definitions
# =======================================================================

# Lil' structure with useful info and methods for special characters.
# 
class NRSER::Char::AlphaNumericSub

  # Attributes
  # ======================================================================
  
  # The `a` character (as a length 1 {String}), the `#ord` of which is used
  # to determine the target `#ord` of lower-case alpha (`a-z`) characters for
  # substitution.
  # 
  # @return [String]
  #   When the sub supports lower-case alpha substitution.
  # 
  # @return [nil]
  #   When the sub does not support lower-case alpha substitution.
  #     
  attr_reader :sub_a
  
  
  # The `A` character (as a length 1 {String}), the `#ord` of which is used
  # to determine the target `#ord` upper-case alpha (`A-Z`) characters for
  # substitution.
  # 
  # @return [String]
  #   When the sub supports upper-case alpha substitution.
  # 
  # @return [nil]
  #   When the sub does not support upper-case alpha substitution.
  #     
  attr_reader :sub_A
  
  
  # The target set's `0` character (as a length 1 {String}), the `#ord` of
  # which is used to determine the target `#ord` of numeric `0-9` characters
  # for substitution.
  # 
  # @return [String]
  #   When the sub supports numeric substitution.
  # 
  # @return [nil]
  #   When the sub does not support numeric substitution.
  #     
  attr_reader :sub_0
  
  
  # Map of source character to dest character substitutions to handle cases
  # where a few of the destination alpha-numerics don't follow the "offest
  # from `a`/`A`/`0`" rule.
  # 
  # @return [Hash<String, String>]
  #   All length 1 UTF-8 strings. Deeply frozen.
  #     
  attr_reader :exceptions
  
  
  # Class Methods
  # ============================================================================
  
  # @!group On-Demand Built-In Instances (Class Methods)
  # ----------------------------------------------------------------------------
  # 
  # Class functions that create "built-in" instances on demand. Doing it like
  # this side-steps load-order issues with using the refinements.
  # 
  
  # Instance to substitute alphas with their "Unicode Math Italic"
  # counterpart.
  # 
  # @return [NRSER::Char::AlphaNumericSub]
  # 
  def self.unicode_math_italic
    @@unicode_math_italic ||= new \
     sub_a: '𝑎',
     sub_A: '𝐴',
     # Doesn't have italic numbers to just don't sub
     exceptions: {
       # The `h` is not in the run
       'h' => 'ℎ'
     }
  end # .unicode_math_italic
  
  
  # Instance to substitute alphas with their "Unicode Math Bold"
  # counterpart.
  # 
  # @return [NRSER::Char::AlphaNumericSub]
  # 
  def self.unicode_math_bold
    @@unicode_math_italic ||= new \
     sub_a: '𝐚',
     sub_A: '𝐀',
     sub_0: '𝟬'
  end # .unicode_math_italic
  
  
  # Instance to substitute alphas with their "Unicode Math Bold Italic"
  # counterpart.
  # 
  # @return [NRSER::Char::AlphaNumericSub]
  # 
  def self.unicode_math_bold_italic
    @@unicode_math_italic ||= new \
     sub_A: '𝑨',
     sub_a: '𝒂',
     # Just use the bold numbers since Unicode doesn't seem to have
     # italic numbers
     sub_0: '𝟬'
  end # .unicode_math_italic
  
  
  # Instance to substitute alphas with their "Unicode Math Bold Italic"
  # counterpart.
  # 
  # @return [NRSER::Char::AlphaNumericSub]
  # 
  def self.unicode_math_monospace
    @@unicode_math_italic ||= new \
     sub_A: '𝙰',
     sub_a: '𝚊',
     sub_0: '𝟶'
  end # .unicode_math_italic
  
  # @!endgroup On-Demand Built-In Instances (Class Methods)
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `AlphaNumericSub`.
  # 
  # @param [String] sub_a
  #   Character the lower-case `a` ASCII character gets replaced with.
  # 
  # @param [String] sub_A
  #   Character the upper-case `A` ASCII character gets replaced with.
  # 
  # @param [String] sub_0
  #   Character the `0` gets subbed out for.
  # 
  # @param [Hash?] exceptions
  #   I don't know just read the source.
  # 
  def initialize  sub_a: nil,
                  sub_A: nil,
                  sub_0: nil,
                  exceptions: nil
    binding.locals.tap do |args|
      t.list( t.utf8_char? ).check \
        args.slice( :sub_a, :sub_A, :sub_0 ).values
      
      t.hash_?( keys: t.utf8_char, values: t.utf8_char ).check exceptions
      
      if args.all?( &:nil? )
        raise ArgumentError.new,
          "All arguments can't be `nil` (sub couldn't do anything)"
      end
    end
    
    @sub_a = sub_a.freeze
    @sub_A = sub_A.freeze
    @sub_0 = sub_0.freeze
    @exceptions = if exceptions
      exceptions.each { |k, v| k.freeze; v.freeze }.freeze
    end
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def sub src
    dest = src.dup
    
    if @exceptions
      @exceptions.each do |src_char, dest_char|
        dest.gsub! src_char, dest_char
      end
    end
    
    [
      ['a', /[a-z]/],
      ['A', /[A-Z]/],
      ['0', /[0-9]/],
    ].each do |src_char, regexp|
      src_char_ord = src_char.ord
      start_dest_char = instance_variable_get "@sub_#{ src_char }"
      
      unless start_dest_char.nil?
        start_dest_char_ord = start_dest_char.ord
        
        dest.gsub!( regexp ) { |char|
          NRSER::Char.from_i(
            start_dest_char_ord + (char.ord - src_char_ord)
          )
        }
      end
    end
    
    dest
  end
  
  
  def demo
    sub ['a'..'z', 'A'..'Z', '0'..'9'].map { |_| _.to_a.join }.join
  end
  
end # class NRSER::Char::Special
