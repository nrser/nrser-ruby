Feature: Testing for booly strings with {NRSER::Booly}
  
  I'm evolving the bool-y stuff to be a bit more nuanced... *truthy* and 
  *falsy* are now **no longer negations of each other**.
  
  Background:
    Given I require 'nrser/booly'
  
  
  Scenario Outline: (1) If it's not a {::String}, it's not a *truthy string*
    
    When I call {NRSER::Booly.truthy_string?} with `<value>`
    Then the response is `false`
    
    Examples:
      | value |
      # ----- #
      | true  |
      | 1     |
      | :true |
      | nil   |
  
  
  Scenario Outline: (2) ...nor are non-strings *falsy strings*
    
    When I call {NRSER::Booly.falsy_string?} with `<value>`
    Then the response is `false`
    
    Examples:
      | value  |
      # ------ #
      | false  |
      | 0      |
      | :false |
      | nil    |
  
  
  Scenario Outline: (3) ...and of course non-strings are not *booly strings*
    
    When I call {NRSER::Booly.booly_string?} with `<value>`
    Then the response is `false`
    
    Examples:
      | value  |
      # ------ #
      | true   |
      | 1      |
      | :true  |
      | nil    |
      | false  |
      | 0      |
      | :false |
      | nil    |
  
  
  Scenario Outline: (4) *Truthy strings* are strings like...
    
    When I call {NRSER::Booly.truthy_string?} with <value>
    Then the response is `true`
    
    Examples:
      | value   |
      # ------- #
      | "true"  |
      | "TRUE"  |
      | "TrUe"  |
      | "t"     |
      | "T"     |
      | "YES"   |
      | "Yes"   |
      | "Y"     |
      | "1"     |
      | "ON"    |
  
  
  Scenario Outline: (5) ...and *falsy strings* are strings like...
    
    **NOTE** The *empty string* `""` is *falsy*.
    
    Also, I've come up with far more reasonable ways to spell-out *falsy*-ness
    than *truthy*-ness.
    
    When I call {NRSER::Booly.falsy_string?} with <value>
    Then the response is `true`
    
    Examples:
      | value   |
      # ------- #
      | "false" |
      | "False" |
      | "FALsE" |
      | "f"     |
      | "F"     |
      | "No"    |
      | "no"    |
      | "0"     |
      | "oFF"   |
      | ""      |
      | "NULL"  |
      | "nil"   |
      | "None"  |
  
  
  Scenario Outline: (6) ...and of course all of (4), (5), etc. are *booly strings*
    
    When I call {NRSER::Booly.booly_string?} with <value>
    Then the response is `true`
    
    Examples:
      | value   |
      # ------- #
      | "TRUE"  |
      | "T"     |
      | "YES"   |
      | "f"     |
      | "F"     |
      | "No"    |
      | "nil"   |
      | "None"  |
  
  
  Scenario Outline: (7) However, the great majority of strings are *none* of those
    
    When I call {NRSER::Booly.truthy_string?} with <value>
    Then the response is `false`
    
    When I call {NRSER::Booly.falsy_string?} with <value>
    Then the response is `false`
    
    When I call {NRSER::Booly.booly_string?} with <value>
    Then the response is `false`
    
    Examples:
      | value    |
      # -------- #
      | "blah"   |
      | "empty"  |
      | "不要"    |
      | "NO WAY" |