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

require 'nrser/meta/names'
require 'nrser/regexps/composed'


# Definitions
# =======================================================================

Names = NRSER::Meta::Names

# Given Steps
# ----------------------------------------------------------------------------

### Objects

Given "the object {value}" do |value|
  describe :object, subject: value
end


### Modules

Given "a module:" do |source|
  scope.class_eval source
  module_name = NRSER::Regexps::Composed.
    join( 'module (', NRSER::Meta::Names::Const.pattern, ')' ).
    match( source )[ 1 ]
  describe_module module_name
end


### Classes

Given "a class:" do |string|
  scope.class_eval string
  class_name = NRSER::Regexps::Composed.
    join( 'class (', NRSER::Meta::Names::Const.pattern, ')' ).
    match( string )[ 1 ]
  describe_class class_name
end


Given "the class {class}" do |cls|
  describe :class, subject: cls
end


### Methods

[
  "the (instance )method {method_name}",
  "its method {method_name}"
].each do |template|
  Given template do |method_name|
    describe_method method_name
  end
end


Given "the {described_name}(')(s) method {method_name}" \
do |described_name, method_name|
  describe :method,
    subject: described.
      find_by_human_name!( described_name ).
      subject.
      method( method_name.bare_name )
end


### Parameters

Given "the parameters {params}" \
do |value_strings|
  describe_positional_params value_strings
end


Given "the parameters:" do |table|
  case table.column_names.count
  when 1
    # The table is interpreted as a list of positional values, the last of 
    # which *may* be a block.
    describe_positional_params table.rows.map( &:first )
  when 2
    # The table is interpreted as parameter name/value pairs, with the names
    # in {NRSER::Meta::Names} format (`arg`, `kwd:`, `&block`)
    table.rows.each do |(name, string)|
      name = Names::Param.from name
      describe_param name,
        value_for( string, accept_block: name.block? )
    end
  else
    # We don't handle any other dimensions
    raise NRSER::RuntimeError.new \
      "Parameter table must be 1 or 2 columns, found ",
      table.column_names.count,
      table: table
  end
end


Given "the {param_name} parameter is {raw_expr}" do |param_name, string|
  describe_param \
    param_name,
    value_for( string, accept_block: param_name.block? )
end


Given "the block parameter is {raw_expr}" do |string|
  if described.is_a? NRSER::Described::Parameters
    described.block = value_for string, accept_block: true
  else
    describe :parameters,
      subject: NRSER::Meta::Params.new(
        block: value_for( string, accept_block: true )
      )
  end
end


# When Steps
# ----------------------------------------------------------------------------

### Responses

[
  "I call it with no parameters",
  "I call the method with no parameters"
].each do |template|
  When template do
    describe :response, params: NRSER::Meta::Params.new
  end
end


[
  "I call it( with the parameters)",
  "I call the method( with the parameters)"
].each do |template|
  When template do
    describe :response
  end
end


When "I call {method_name}( with the parameters)" do |method_name|
  describe_method method_name
  describe :response
end


# Then Steps
# ----------------------------------------------------------------------------

Then "the {described_name} is a(n) {class}" do |described_name, cls|
  expect_described( described_name ).to be_a cls
end


Then "it is a(n) {class}" do |cls|
  expect_it.to be_a cls
end


Then "it is a subclass of {class}" do |cls|
  expect_it.to be < cls
end


Then "it is {value}" do |value|
  expect_it.to be value
end


Then "it is equal to {value}" do |value|
  expect_it.to eq value
end


Then "the {described_name} is equal to {value}" do |described_name, value|
  expect_described( described_name ).to eq value
end


Then "the {described_name} is equal to:" do |described_name, string|
  expect_described( described_name ).to eq eval( string )
end


Then "the {described_name} is {value}" \
do |described_name, value|
  expect_described( described_name ).to be value
end


Then "it has a(n) {method_name} attribute equal to {value}" \
do |method_name, value|
  expect_it.to have_attributes method_name => value
end


Then "it has a(n) {method_name} attribute that is {value}" \
do |method_name, value|
  expect_it.to have_attributes method_name => be( value )
end


Then "it has a(n) {method_name} attribute that is a(n) {class}" \
do |method_name, cls|
  expect_it.to have_attributes \
    method_name => be_a( cls )
end
