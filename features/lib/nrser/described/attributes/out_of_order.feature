Feature: Describe attributes "out of order"
  
  Background: 
    Given the attribute `to_s`
  
  Scenario:
    Given the object 1
    Then the attribute is equal to "1"

  Scenario:
    Given the object `Pathname.new '/usr/bin'`
    Then the attribute is equal to "/usr/bin"
  