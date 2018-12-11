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

World ScopeMixin
World DescribeMixins

Given "a class:" do |string|
  scope.class_eval string
  class_name = NRSER::Regexp::Composed.
    join( 'class (', NRSER::Meta::Names::Module.pattern, ')' ).
    match( string )[ 1 ]
  describe_class class_name
end


Then "the {described} is a(n) {class}" do |described_human_name, class_name|
  expect_described( described_human_name ).to be_a resolve_class( class_name )
end


Then "it is a(n) {class}" do |class_name|
  expect_it.to be_a resolve_class( class_name )
end


Then "it has a(n) {attr} attribute equal to {string}" \
do |attribute_name, string|
  expect_it.to have_attributes attribute_name => string
end


Then "it has a(n) {attr} attribute that is a {class}" \
do |attribute_name, class_name|
  expect_it.to have_attributes \
    attribute_name => be_a( resolve_class( class_name ) )
end


# When "I call {method_identifier}" do |method_identifier|
#   describe_method method_identifierresponse
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
