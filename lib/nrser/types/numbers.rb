require 'nrser/refinements'
require 'nrser/types/type'
require 'nrser/types/is_a'
require 'nrser/types/combinators'
require 'nrser/types/bounded'

using NRSER
  
module NRSER::Types
  def self.parse_number s
    float = s.to_f
    int = float.to_i
    if float == int then int else float end
  end
  
  # zero
  # ====
  
  ZERO = is 0, name: 'zero', from_s: method(:parse_number)
  
  def self.zero
    ZERO
  end
  
  # number (Numeric)
  # ================
  
  NUM = IsA.new Numeric, name: 'Num', from_s: method(:parse_number)
  
  def self.num
    NUM
  end
  
  # integers
  # ========
  
  INT = IsA.new Integer, name: 'Int', from_s: method(:parse_number)
  
  def self.int
    INT
  end
  
  def self.integer
    int
  end
  
  # bounded integers
  # ================
  # 
  
  # positive integer
  # ----------------
  # 
  # integer greater than zero.
  # 
  
  POS_INT = intersection INT, bounded(min: 1), name: 'PosInt'
  
  def self.pos_int
    POS_INT
  end
  
  # negative integer
  # ----------------
  # 
  # integer less than zero
  # 
  
  NEG_INT = intersection INT, bounded(max: -1), name: 'NegInt'
  
  def self.neg_int
    NEG_INT
  end
  
  # non-negative integer
  # --------------------
  # 
  # positive integers and zero... but it seems more efficient to define these
  # as bounded instead of a union. 
  # 
  
  NON_NEG_INT = intersection INT, bounded(min: 0), name: 'NonNegInt'
  
  def self.non_neg_int
    NON_NEG_INT
  end
  
  # non-positive integer
  # --------------------
  # 
  # negative integers and zero.
  # 
  
  NON_POS_INT = intersection INT, bounded(max: 0), name: 'NonPosInt'
  
  def self.non_pos_int
    NON_POS_INT
  end
   
end # NRSER::Types