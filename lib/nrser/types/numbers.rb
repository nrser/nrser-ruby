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
  def self.parse_number string
    float = Float string
    int = float.to_i
    if float == int then int else float end
  end
  
  
  # Zero
  # =====================================================================
  
  def_factory :zero do |from_s: method( :parse_number ), **options|
    is \
      0,
      from_s: from_s,
      **options
  end
  
  
  # Number ({Numeric})
  # =====================================================================
  
  def_factory(
    :num,
    aliases: [ :number, :numeric ],
  ) do |from_s: method( :parse_number ), **options|
    IsA.new \
      Numeric,
      from_s: from_s,
      **options
  end
  
  
  # Integers
  # =====================================================================
  
  def_factory(
    :int,
    aliases: [ :integer, :signed ],
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
    :pos_int,
    aliases: [ :positive_int, :positive_integer ]
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
    :neg_int,
    aliases: [ :negative_int, :negative_integer ],
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
    :non_neg_int,
    aliases: [ :unsigned, :index, :non_negative_int, :non_negative_integer ],
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
    :non_pos_int,
    aliases: [ :non_positive_int, :non_positive_integer ],
  ) do |name: '{0}∪ℤ⁻', **options|
    intersection \
      int,
      bounded( max: 0 ),
      name: name,
      **options
  end
   
end # NRSER::Types
