# Feature: Construct an instance of a {::Class} identified by name
  
#   Scenario: (1)
    
#     Given no arguments
#     And I construct an instance of {String}
    
#     Then the instance is a {String}
#     And it is equal to ""
    
    
#   Scenario: (2)
    
#     Given no arguments
#     And I construct a {String}
    
#     Then the instance is a {String}
#     And it is equal to ""
  
  
#   Scenario: (3)
    
#     Given empty arguments
#     And I construct a {String} from the arguments
    
#     Then the instance is a {String}
#     And it is equal to ""
    
    
#   Scenario: (3) Positional arguments table
    
#     Given I construct a {String} from the arguments:
#       | VALUE   |
#       | "Hey!"  |
    
#     Then the instance is a {String}
#     And it is equal to "Hey!"
    
    
#   Scenario: (4) Free-form arguments block
#     Given the class:
#       """ruby
#       class A
#         attr_reader :args
#         attr_reader :kwds
        
#         def initialize *args, **kwds
#           @args = args
#           @kwds = kwds
#         end
#       end
#       """
    
#     Given I construct an instance of {A} from the arguments:
#       """ruby
#       :one, :two, three: 3, four: 4
#       """
    
#     Then the instance is a {A}
#     And it has an `args` attribute that is equal to `[ :one, :two ]`