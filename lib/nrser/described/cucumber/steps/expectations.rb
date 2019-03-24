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
  
  Step "the {described_name} is a(n) {class}" do |described_name, cls|
    expect_described( described_name ).to be_a cls
  end
  
  
  Step "the {described} is an instance of the {described}" \
  do |described_object, described_class|
    expect_described( described_object ).
      to be_a described_class.resolve!( hierarchy ).subject
    
    # Need to touch the object again since it's the subject
    hierarchy.touch described_object
  end
  
  
  Step "it is a(n) {class}" do |cls|
    expect_it.to be_a cls
  end
  
  
  Step "it is a subclass of {class}" do |cls|
    expect_it.to be < cls
  end
  
  
  Step "it is {value}" do |value|
    expect_it.to be value
  end
  
  
  Step "it is equal to {value}" do |value|
    expect_it.to eq value
  end
  
  
  Step "it is NOT equal to {value}" do |value|
    expect_it.not_to eq value
  end
  
  
  Step "the {described} is equal to {value}" do |described, value|
    expect( subject ).to eq value
  end

  
  Step "the {described} is equal to:" do |described, string|
    expect( subject ).to eq eval( string )
  end
    
    
  Step "the {described} is equal to the string:" do |described, string|
    expect( subject ).to eq string
  end

  
  Step "the {described_name} is {value}" \
  do |described_name, value|
    expect_described( described_name ).to be value
  end
  
  
  Step "it has a(n) {method_name} attribute equal to {value}" \
  do |method_name, value|
    expect_it.to have_attributes method_name.bare_name => value
  end

  
  Step "it has a(n) {method_name} attribute that is {value}" \
  do |method_name, value|
    expect_it.to have_attributes method_name.bare_name => be( value )
  end

  
  Step "it has a(n) {method_name} attribute that is a(n) {class}" \
  do |method_name, cls|
    expect_it.to have_attributes \
      method_name.bare_name => be_a( cls )
  end

  
  Step "the {described} has a(n) {method_name} attribute that is a(n) {class}" \
  do |described, method_name, cls|
    expect( subject ).to have_attributes \
      method_name.bare_name => be_a( cls )
  end
    
  
  Step "the {described} has a(n) {method_name} attribute that is {value}" \
  do |described, method_name, value|
    expect_described( described ).to have_attributes \
      method_name.bare_name => be( value )
  end
    
  
  Step "the {described} has a {value} key with value {value}" \
  do |described, key, value|
    expect_described( described ).to include key => value
  end
  
  
  Step "it has a {value} key with value {value}" \
  do |key, value|
    expect_it.to include key => value
  end
  
  
  Step "{local_var_name} is equal to {value}" do |local_var_name, value|
    expect( resolve_let local_var_name ).to eq value
  end
  
  
  Step "{local_var_name} is equal to the string:" do |local_var_name, string|
    expect( resolve_let local_var_name ).to eq string
  end
  
  
  Step "{local_var_name} is a(n) {class}" do |local_var_name, cls|
    expect( resolve_let local_var_name, describe: true ).to be_a cls
  end

end # module Expectations

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
