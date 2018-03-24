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
  
  def_factory :pos_int do |name: 'ℤ⁺', **options|
    all_of \
      int,
      bounded( min: 1 ),
      name: name,
      **options
  end
  
  # Ugh sometimes the naturals have 0, so omit it...
  # singleton_class.send :alias_method, :natural, :pos_int
  
  
  # Negative Integer
  # ----------------
  # 
  # Integer less than zero.
  # 
  
  def self.neg_int
    intersection(
      INT,
      bounded(max: -1),
      name: 'ℤ⁻'
    ).freeze
  end
  
  
  # Non-Negative Integer
  # --------------------
  # 
  # Positive integers and zero... but it seems more efficient to define these
  # as bounded instead of a union.
  # 
  
  def self.non_neg_int **options
    # Alternative symbol: 'ℤ⋆'
    intersection INT, bounded(min: 0), name: '{0}∪ℤ⁺', **options
  end
  
  singleton_class.send :alias_method, :unsigned, :non_neg_int
  
  
  def self.non_neg_int? **options
    maybe non_neg_int, **options
  end
  
  singleton_class.send :alias_method, :unsigned?, :non_neg_int?
  
  
  # Non-Positive Integer
  # --------------------
  # 
  # negative integers and zero.
  # 
  
  def self.non_pos_int **options
    intersection INT, bounded(max: 0), name: '{0}∪ℤ⁻', **options
  end
   
end # NRSER::Types
