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


# Given
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

Given "the {described}(')(s) method {method}" \
do |described_human_name, method_name|
  describe Described::Method.new \
    parent: described,
    subject: described.
              find_by_human_name!( described_human_name ).
              subject.
              method( method_name.method_name )
end


# Then
# ----------------------------------------------------------------------------

Then "the {described} is a(n) {class}" \
do |described_human_name, class_name|
  expect_described( described_human_name ).to be_a resolve_class( class_name )
end


Then "it is a(n) {class}" \
do |class_name|
  expect_it.to be_a resolve_class( class_name )
end


Then "it is a subclass of {class}" \
do |class_name|
  expect_it.to be < resolve_class( class_name )
end


Then "it has a(n) {attr} attribute equal to {string}" \
do |attribute_name, string|
  expect_it.to have_attributes attribute_name => string
end


Then "it has a(n) {attr} attribute equal to {expr}" \
do |attribute_name, source|
  expect_it.to have_attributes attribute_name => eval( source )
end


Then "it has a(n) {attr} attribute that is a {class}" \
do |attribute_name, class_name|
  expect_it.to have_attributes \
    attribute_name => be_a( resolve_class( class_name ) )
end


# When "I call {method_identifier}" do |method_identifier|
#   describe_method method_identifier
# end

# When "the {param_name} parameter is {expr}" do |param_name, string|
#   describe_param param_name, eval( string )
# end

# Then "the {subject} is a(n) {class_name}" do |class_name|
#   expect( described.subject ).to be_a resolve_class( class_name )
# end

# Then "the {subject} has a(n) {method_name} attribute that is {expr}" \
# do |subject, method_name, string|
#   expect( subject ).to have_attributes method_name => be( eval( string ) )
# end

# Then "it has a(n) {method_name} attribute that is {expr}" \
# do |method_name, expr|
#   expect_it.to have_attributes method_name => be( eval( string ) )
# end
