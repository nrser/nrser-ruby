# This is wishlist shit at this point...
# 
# Feature: {NRSER::Meta::Names::Var::Global} matches global variable names
  
#   By "Global", I mean "Starts with `$`" - there are a few pre-defined `$`-vars
#   that are dynamically-set *locals*: The regular expression ones - `$~`, `$1`,
#   etc. - and maybe some more I'm not remembering.
  
#   {NRSER::Meta::Names::Var::Global} is meant to match those too.
  
#   Scenario: Match "common" global variable names
    
#     Given the class {NRSER::Meta::Names::Var::Global}, requiring 'nrser/meta/names'
    
#     And each {String}:
#       | VALUE   |
#       | "$BLAH" |
#       | "$X"    |
#       | "$_X"   |
    
#     When I construct an instance the class from a string
    
#     Then the instance is an instance of the class
#     And its {#common?} method returns `true`
    