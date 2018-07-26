# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Namespace
# =======================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================

# @todo document Document class.
class Document < Type
  
  # Constants
  # ========================================================================
  
  
  # Class Methods
  # ========================================================================
  
  
  # Attributes
  # ========================================================================
  
  
  # Construction
  # ========================================================================
  
  # Instantiate a new `Document`.
  def initialize spec
    @spec = spec
  end # #initialize
  
  
  # Instance Methods
  # ========================================================================
  
  def test_term_value? term_value, doc_value
    case doc_value
    when bag
      
  end


  def test_term? term_key, term_value, doc
    case key
    when Type
      doc.each_pair { |doc_key, doc_value|
        if term_key === doc_key
          return false unless test_term_value?( term_value, doc_value )
        end
      }
    else
      test_term_value? term_value, doc[term_key]
    end
  end


  def test? doc
    return false unless doc.respond_to?( :each_pair ) &&
                        doc.respond_to?( :[] )

    @spec.all? { |key, value| test_term? key, value, doc }
  end
  
end # class Document


# /Namespace
# =======================================================================

end # module Types
end # module NRSER
