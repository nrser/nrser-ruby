Feature: Decorate methods
  
  Scenario Outline: Decorate
    Given a 
  
    Given a(n) <decorated method type> method <decorated method name> to decorate
    And a decorator <decorator method type> method <decorator method name>
    And and decoration is declared 
    
    When A#f is called
    Then it works
  
  Examples:
    | decorated method type | decorator |
    | instance              | instance method name |
    | singleton             | singleton method name |
  
  
  

  