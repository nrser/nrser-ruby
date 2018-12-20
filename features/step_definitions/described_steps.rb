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
  describe_params \
    *table.rows.map { |row|
      string = row.first
      
      if expr? string
        eval backtick_unquote( string )
      else
        raise NotImplementedError,
              "TODO can only handle expr strings so far"
      end
    }
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


When "the {param} parameter is {expr}" do |param_name, source|
  describe_param param_name, eval( source )
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


Then "the {described} is equal to {string}" \
do |described_human_name, string|
  expect_described( described_human_name ).to eq string
end


Then "the {described} is equal to {expr}" \
do |described_human_name, source|
  expect_described( described_human_name ).to eq eval( source )
end


Then "it has a(n) {attr} attribute equal to {string}" \
do |attribute_name, string|
  expect_it.to have_attributes attribute_name => string
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
