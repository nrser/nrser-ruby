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
require 'nrser/regexp/composed'


# Definitions
# =======================================================================

# Mixins
# ----------------------------------------------------------------------------

World ScopeMixin
World DescribeMixins


# Given Steps
# ----------------------------------------------------------------------------

### Objects

Given "the object {expr}" do |source|
  describe :object, subject: eval( source )
end


### Modules

Given "a module:" do |source|
  scope.class_eval source
  module_name = NRSER::Regexp::Composed.
    join( 'module (', NRSER::Meta::Names::Module.pattern, ')' ).
    match( source )[ 1 ]
  describe_module module_name
end


### Classes

Given "a class:" \
do |string|
  scope.class_eval string
  class_name = NRSER::Regexp::Composed.
    join( 'class (', NRSER::Meta::Names::Module.pattern, ')' ).
    match( string )[ 1 ]
  describe_class class_name
end


Given "the class {class}" \
do |class_name|
  describe_class class_name
end


### Methods

Given "the (instance )method {qualified_method}" \
do |method_name|
  describe_method method_name
end


Given "the {described}(')(s) method {method}" \
do |described_human_name, method_name|
  describe Described::Method.new \
    parent: described,
    subject: described.
              find_by_human_name!( described_human_name ).
              subject.
              method( method_name.method_name )
end


Given "its method {method}" \
do |method_name|
  describe_method method_name
end


### Parameters

Given "the parameters {exprs}" \
do |sources|
  describe_params \
    *sources.map { |source| eval source }
end


Given "the parameters:" do |table|
  
  case table.column_names.count
  when 1
    describe_params *table.rows.map { |row| value_for row.first }
  when 2
    table.rows.each do |(name, string)|
      describe_param name, value_for( string )
    end
  else
    raise "Parameter table must be 1 or 2 columns, found #{ table.column_names.count }"
  end

end


Given "the {param} parameter is {expr}" do |param_name, source|
  describe_param param_name, eval( source )
end


Given "the block parameter is {expr}" do |source|
  if described.is_a? Described::Parameters
    described.block = eval source
  else
    describe Described::Parameters.new \
      parent: described,
      subject: NRSER::Meta::Params.new( block: eval( source ) )
  end
end


# When Steps
# ----------------------------------------------------------------------------

### Responses

[ "I call it with no parameters",
  "I call the method with no parameters" ].each do |pattern|
  When pattern do
    describe_response params: NRSER::Meta::Params.new
  end
end


[ "I call it( with the parameters)",
   "I call the method( with the parameters)" ].each do |pattern|
  When pattern do
    describe_response
  end
end


# Then Steps
# ----------------------------------------------------------------------------

Then "the {described} is a(n) {class}" \
do |described_human_name, class_name|
  expect_described( described_human_name ).to be_a resolve_class( class_name )
end


Then "it is a(n) {class}" do |class_name|
  expect_it.to be_a resolve_class( class_name )
end


Then "it is a subclass of {class}" do |class_name|
  expect_it.to be < resolve_class( class_name )
end


Then "it is equal to {string}" do |string|
  expect_it.to eq string
end


Then "the {described} is equal to {expr}" \
do |described_human_name, source|
  expect_described( described_human_name ).to eq eval( source )
end


Then "the {described} is equal to:" \
do |described_human_name, source|
  expect_described( described_human_name ).to eq eval( source )
end


Then "the {described} is {expr}" \
do |described_human_name, source|
  expect_described( described_human_name ).
    to be eval( backtick_unquote source  )
end


Then "it has a(n) {attr} attribute equal to {expr}" \
do |attribute_name, source|
  expect_it.to have_attributes attribute_name => eval( source )
end


Then "it has a(n) {attr} attribute that is {expr}" \
do |attribute_name, source|
  expect_it.to have_attributes attribute_name => be( eval( source ) )
end


Then "it has a(n) {attr} attribute that is a(n) {class}" \
do |attribute_name, class_name|
  expect_it.to have_attributes \
    attribute_name => be_a( resolve_class( class_name ) )
end
