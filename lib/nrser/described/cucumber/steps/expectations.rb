# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Extending in {Helpers}
require_relative './helpers'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Definitions
# =======================================================================

module Expectations
  
  # Mixins
  # ==========================================================================
  
  extend Helpers
  
  
  # Steps
  # ==========================================================================
  
  X_IS_A = \
    Step "the {described_name} is a(n) {class}" do |described_name, cls|
      expect_described( described_name ).to be_a cls
    end
  
  
  IT_IS_A = \
    Step "it is a(n) {class}" do |cls|
      expect_it.to be_a cls
    end
  
  
  IT_IS_A_SUBCLASS_OF = \
    Step "it is a subclass of {class}" do |cls|
      expect_it.to be < cls
    end
  
  
  IT_IS = \
    Step "it is {value}" do |value|
      expect_it.to be value
    end
  
  
  IT_IS_EQUAL_TO = \
    Step "it is equal to {value}" do |value|
      expect_it.to eq value
    end
    
    
  IT_IS_NOT_EQUAL_TO = \
    Step "it is NOT equal to {value}" do |value|
      expect_it.not_to eq value
    end
  
  
  X_IS_EQUAL_TO_INLINE = \
    Step "the {described} is equal to {value}" do |described, value|
      expect( subject ).to eq value
    end

  
  X_IS_EQUAL_TO_SRC = \
    Step "the {described} is equal to:" do |described, string|
      expect( subject ).to eq eval( string )
    end

  
  X_IS_INLINE = \
    Step "the {described_name} is {value}" \
    do |described_name, value|
      expect_described( described_name ).to be value
    end

  IT_HAS_ATTR_EQUAL_TO = \
    Step "it has a(n) {method_name} attribute equal to {value}" \
    do |method_name, value|
      expect_it.to have_attributes method_name => value
    end

  
  IT_HAS_ATTR_THAT_IS = \
    Step "it has a(n) {method_name} attribute that is {value}" \
    do |method_name, value|
      expect_it.to have_attributes method_name => be( value )
    end

  
  IT_HAS_ATTR_THAT_IS_A = \
    Step "it has a(n) {method_name} attribute that is a(n) {class}" \
    do |method_name, cls|
      expect_it.to have_attributes \
        method_name => be_a( cls )
    end
  
  
  THE_X_HAS_ATTR_THAT_IS_A = \
    Step "the {described} has a(n) {method_name} attribute that is a(n) {class}" \
    do |described, method_name, cls|
      expect( subject ).to have_attributes \
        method_name => be_a( cls )
    end
  
  Step "the {described} has a {value} key with value {value}" \
  do |described, key, value|
    expect( subject ).to include key => value
  end

end # module Expectations

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
