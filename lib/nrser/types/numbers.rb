require 'nrser/types/type'
require 'nrser/types/is_a'
require 'nrser/types/combinators'
require 'nrser/types/bounded'

  
module NRSER::Types
  # Parse a string into a number.
  # 
  # @return [Integer]
  #   If the string represents a whole integer.
  # 
  # @return [Float]
  #   If the string represents a decimal number.
  # 
  def self.parse_number string
    float = Float string
    int = float.to_i
    if float == int then int else float end
  end
  
  
  # Zero
  # =====================================================================
  
  def_factory(
    :Zero,
    aliases: [ :zero ],
  ) do |from_s: method( :parse_number ), **options|
    is \
      0,
      from_s: from_s,
      **options
  end
  
  
  # Number ({Numeric})
  # =====================================================================
  
  def_factory(
    :Number,
    aliases: [ :num, :number, :numeric, :Numeric ],
  ) do |name: 'Number', from_s: method( :parse_number ), **options|
    IsA.new \
      Numeric,
      from_s: from_s,
      **options
  end
  
  
  # Integers
  # =====================================================================
  
  def_factory(
    :Integer,
    aliases: [ :int, :integer, :signed ],
  ) do |name: 'ℤ', from_s: method( :parse_number ), **options|
    IsA.new \
      Integer,
      from_s: from_s,
      **options
  end
  
  
  # Bounded Integers
  # ---------------------------------------------------------------------
  
  # Positive Integer
  # ----------------
  # 
  # Integer greater than zero.
  # 
  
  def_factory(
    :PositiveInteger,
    aliases: [ :pos_int, :positive_int, :positive_integer ]
  ) do |name: 'ℤ⁺', **options|
    intersection \
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
  
  def_factory(
    :NegativeInteger,
    aliases: [ :neg_int, :negative_int, :negative_integer ],
  ) do |name: 'ℤ⁻', **options|
    intersection \
      int,
      bounded( max: -1 ),
      name: name,
      **options
  end
  
  
  # Non-Negative Integer
  # --------------------
  # 
  # Positive integers and zero... but it seems more efficient to define these
  # as bounded instead of a union.
  # 
  
  def_factory(
    :NonNegativeInteger,
    aliases: [
      :non_neg_int,
      :unsigned,
      :index,
      :non_negative_int,
      :non_negative_integer,
    ],
  ) do |name: 'ℕ⁰', **options|
    intersection \
      int,
      bounded( min: 0 ),
      name: name,
      **options
  end
  
  
  # Non-Positive Integer
  # --------------------
  # 
  # negative integers and zero.
  # 
  
  def_factory(
    :NonPositiveInteger,
    aliases: [ :non_pos_int, :non_positive_int, :non_positive_integer ],
  ) do |name: '{0}∪ℤ⁻', **options|
    intersection \
      int,
      bounded( max: 0 ),
      name: name,
      **options
  end
  
  
  def_factory(
    :Unsigned16BitInteger,
    aliases: [ :uint16, :ushort ],
  ) do |name: 'uint16', **options|
    intersection \
      int,
      bounded( min: 0, max: ((2 ** 16) - 1) ),
      name: name,
      **options
  end
  
  
  # TODO  Move?
  def_factory(
    :UNIXPort,
    aliases: [ :port, ],
  ) do |name: 'port', **options|
    intersection \
      int,
      bounded( min: 1, max: (2**16 - 1) ),
      name: name,
      **options
  end
  
end # NRSER::Types
