require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is_a'
require 'nrser/types/combinators'
require 'nrser/types/bounded'

using NRSER
  
module NRSER::Types
  # Parse a string into a number.
  # 
  # @return [Integer]
  #   If the string represents a whole integer.
  # 
  # @return [Float]
  #   If the string represents a decimal number.
  # 
  def self.parse_number s
    float = Float s
    int = float.to_i
    if float == int then int else float end
  end
  
  
  # Zero
  # =====================================================================
  
  ZERO = is(
    0,
    name: 'ZeroType',
    from_s: method( :parse_number )
  ).freeze
  
  def self.zero
    ZERO
  end
  
  
  # Number ({Numeric})
  # =====================================================================
  
  NUM = IsA.new(
    Numeric,
    name: 'NumType',
    from_s: method( :parse_number )
  ).freeze
  
  def self.num
    NUM
  end
  
  singleton_class.send :alias_method, :number, :num
  
  
  # Integers
  # =====================================================================
  
  INT = IsA.new(
    Integer,
    name: 'IntType',
    from_s: method( :parse_number )
  ).freeze
  
  def self.int
    INT
  end
  
  singleton_class.send :alias_method, :integer, :int
  
  
  # Bounded Integers
  # ---------------------------------------------------------------------
  
  # Positive Integer
  # ----------------
  # 
  # Integer greater than zero.
  # 
  
  POS_INT = intersection(
    INT,
    bounded(min: 1),
    name: 'PosIntType'
  ).freeze
  
  def self.pos_int
    POS_INT
  end
  
  
  # Negative Integer
  # ----------------
  # 
  # Integer less than zero.
  # 
  
  NEG_INT = intersection(
    INT,
    bounded(max: -1),
    name: 'NegIntType'
  ).freeze
  
  def self.neg_int
    NEG_INT
  end
  
  
  # Non-Negative Integer
  # --------------------
  # 
  # Positive integers and zero... but it seems more efficient to define these
  # as bounded instead of a union. 
  # 
  
  NON_NEG_INT = intersection INT, bounded(min: 0), name: 'NonNegIntType'
  
  def self.non_neg_int
    NON_NEG_INT
  end
  
  singleton_class.send :alias_method, :unsigned, :non_neg_int
  
  
  # Non-Positive Integer
  # --------------------
  # 
  # negative integers and zero.
  # 
  
  NON_POS_INT = intersection INT, bounded(max: 0), name: 'NonPosIntType'
  
  def self.non_pos_int
    NON_POS_INT
  end
   
end # NRSER::Types