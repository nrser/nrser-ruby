Feature: {NRSER::Text::Writer} Dev Tests
  
  Scenario:
    Given I require 'nrser/text/writer'
    And the class {NRSER::Text::Writer}
    And I let `io` be `StringIO.new`
    And I let `string` be the string:
      """
      Hey there!
      """
    
    When I construct an instance of the class with `{ io: io, line_width: 24 }`
    And I call `write` on the instance with `string`
    
    Then the instance has a `line_buffer` attribute
    And it is equal to `string`
    
    When I call `close` on the instance with no arguments
    And I let `result` be `io.string`
    
    Then `result` is equal to the string:
      """
      Hey there!
      """