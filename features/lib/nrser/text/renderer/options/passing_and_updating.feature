Feature: Check out option defaults work on {NRSER::Text::Renderer::Options}

  Background:
    Given I require "nrser/text/renderer/options"
    And the class {NRSER::Text::Renderer::Options}
  
  
  Scenario:
    
    Given a module:
      """ruby
      module A
        
        def self.default_options
          @options ||= NRSER::Text::Renderer::Options.new
        end
        
        
        def self.f options = nil
          options = self.default_options.merge options
          
          g options
        end
        
        
        def self.g options = nil
          options = self.default_options.merge options
          
          options
        end
        
      end
      """
    
    When I call {A.f} with no arguments
    
    Then the response is a {NRSER::Text::Renderer::Options}
    And it is `A.default_options`
    
