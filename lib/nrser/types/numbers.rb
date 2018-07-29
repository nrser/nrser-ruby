require 'nrser/types/type'
require 'nrser/types/is_a'
require 'nrser/types/combinators'
require 'nrser/types/bounded'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================


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

def_type(
  :Zero,
  aliases: [ :zero ],
) do |from_s: method( :parse_number ), **options|
  is \
    0,
    from_s: from_s,
    **options
end


# Numeric
# =====================================================================

# @!method Numeric **options
#   The Ruby {Numeric} type, which is the super-class of all number classes:
#   {Integer}, {Float}, {Rational}, {Complex}.
#   
#   In set theory notation this would either be expressed as either:
#   
#   1.  ℤ ∪ ℚ ∪ ℝ ∪ ℂ
#   2.  ℂ
#   
#   depending on how you want to thing about the embeddability of the sets
#   within each other (ℤ is embeddable in ℚ, which is embeddable in ℝ, which
#   is embeddable in ℂ).
#   
#   However, I feel like (2) is not at all useful for expressing the type,
#   and I feel like the default of just using the {Type#name} as the 
#   {Type#symbolic} is easier to read than (1), so this type does not provide
#   a `symbolic:` keyword argument.
#   
#   @return [Type]
#     A type whose members are all instances of Ruby's {Numeric} class.
# 
def_type    :Numeric,
  aliases:  [ :num, :number, :numeric ],
  # symbolic: [ INTEGERS,
  #             RATIONALS,
  #             REALS,
  #             COMPLEXES ].join( " #{ UNION } " ),
  from_s:   method( :parse_number ) \
do |**options|
  IsA.new Numeric, **options
end


# Integers
# =====================================================================

# @!method Integer **options
#   Instances of the built-in {Integer} class.
#   
#   @param [Hash] **options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
# 
def_type(
  :Integer,
  symbolic: 'ℤ',
  from_s: method( :parse_number ),
  aliases: [ :int, :integer, :signed ],
) do |**options|
  IsA.new Integer, **options
end


# Bounded Integers
# ---------------------------------------------------------------------

# Positive Integer
# ----------------
# 
# Integer greater than zero.
# 

def_type(
  :PositiveInteger,
  symbolic: 'ℤ⁺',
  aliases: [ :pos_int, :positive_int ]
) do |**options|
  intersection \
    self.Integer,
    bounded( min: 1 ),
    **options
end

# Ugh sometimes the naturals have 0, so omit it...
# singleton_class.send :alias_method, :natural, :pos_int


# Negative Integer
# ----------------
# 
# Integer less than zero.
# 

def_type      :NegativeInteger,
  symbolic:   'ℤ⁻',
  aliases:  [ :neg_int,
              :negative_int ] \
do |**options|
  intersection \
    self.Integer,
    self.Bounded( max: -1 ),
    **options
end


def_type      :NegativeInteger,
  symbolic:   'ℤ⁻',
  aliases:  [ :neg_int,
              :negative_int ] \
do |**options|
  intersection \
    self.Integer,
    self.Bounded( max: -1 ),
    **options
end


# Non-Negative Integer
# --------------------
# 
# Positive integers and zero... but it seems more efficient to define these
# as bounded instead of a union.
# 

def_type      :NonNegativeInteger,
  symbolic:   'ℕ⁰',
  aliases:  [ :non_neg_int,
              :unsigned,
              :index,
              :non_negative_int, ] \
do |**options|
  intersection \
    self.Integer,
    self.Bounded( min: 0 ),
    **options
end


# Non-Positive Integer
# --------------------
# 
# negative integers and zero.
# 

def_type      :NonPositiveInteger,
  symbolic:   '{0}∪ℤ⁻',
  aliases:  [ :non_pos_int,
              :non_positive_int,
              :non_positive_integer ],
&->( **options ) do
  intersection \
    self.Integer,
    self.Bounded( max: 0 ),
    **options
end


def_type      :Unsigned16BitInteger,
  symbolic:   'uint16',
  aliases:  [ :uint16,
              :ushort ],
&->( **options ) do
  intersection \
    self.Integer,
    self.Bounded( min: 0, max: ((2 ** 16) - 1) ),
    **options
end


# TODO  Move?
def_type      :UNIXPort,
  aliases:  [ :port, ],
&->( **options ) do
  intersection \
    self.Integer,
    self.Bounded( min: 1, max: (2**16 - 1) ),
    **options
end


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
