Feature: {NRSER::Text::Renderer::Options} - Passing and Updating

  Background:
    Given I require "nrser/text/renderer/options"
    And the class {NRSER::Text::Renderer::Options}
  
  
  Scenario: (1) Options can be merged with itself or `nil` without change
    
    Since text generation is intended for use in relatively low-level code
    like error messages and potentially very frequent situations like logging,
    it should be reasonably performant... or, at least, architected in a way
    that would allow for it to be optimized as needed.
    
    {Options} get passed down through nested rendering calls, sometimes with 
    modifications for the current method or sub-calls, but often without. I like
    Options being immutable, but also want to avoid unnecessary copies and the
    waste and allocations they bring.
    
    For those reasons I've settled on the following pattern: an options argument
    is given as the last argument, which may be `nil`, an {Options}, or a
    {::Hash}, which get merged with the default options.
    
    If the options argument is `nil`, {#merge} just returns the instance itself.
    
    If it is a *different* {Options}, then a merge is performed as expected, 
    resulting in a new {Options} instance. However, if {#merge} is given the
    *same* {Options} instance, then it just returns itself, allowing for the
    default options to get passed down through calls without additional copies
    or allocations unless they are modified at some point - which creates a new
    {Options} instance since {Options} are immutable.
    
    Given a module:
      """ruby
      module A
        
        def self.default_options
          @options ||= NRSER::Text::Renderer::Options.new
        end
        
        
        def self.f options = nil
          options = default_options.merge options
          
          g options
        end
        
        
        def self.g options = nil
          options = default_options.merge options
          
          options
        end
        
      end
      """
    
    When I call {A.f} with `nil`
    
    Then the response is a {NRSER::Text::Renderer::Options}
    
    # We end up with the *exact same* instance:
    # 
    # 1.  The call to {A.f} receives `nil` and merges that with 
    #     {A.default_options}, which just returns {A.default_options}
    # 
    # 2.  The call to {A.g} is then given {A.default_options}, which is merged
    #     with {A.default_options}, just resulting in the same object getting
    #     returned, which {A.g} returns.
    # 
    And it is `A.default_options`
    
    # However, passing a hash to {A.f} works as expected
    
    When I call {A.f} with `{ word_wrap: 88, code_indent: 8 }`
    
    Then the response is a {NRSER::Text::Renderer::Options}
    
    # Response {Options} is a new instance with the changes
    And it is NOT `A.default_options`
    And the response has a `word_wrap` attribute that is `88`
    And the response has a `code_indent` attribute that is `8`


  Scenario: (2) Using {#update} to create modified versions
    
    Given a module:
      """ruby
      module A
        
        def self.default_options
          @options ||= NRSER::Text::Renderer::Options.new
        end
        
        
        def self.update_with_value options = nil
          options = default_options.merge options
          
          if options.word_wrap != false
            options = options.update  :word_wrap,
                                      options.word_wrap - options.code_indent
          end
          
          options
        end
        
        
        def self.update_with_block options = nil
          options = default_options.merge options
          
          if options.word_wrap != false
            options = options.update :word_wrap do |current|
              current - options.code_indent
            end
          end
          
          options
        end
        
      end
      """
      
    When I call {A.update_with_value} with `{ word_wrap: 80, code_indent: 4 }`
    
    Then the response is a {NRSER::Text::Renderer::Options}
    And it is NOT `A.default_options`
    And it has a `word_wrap` attribute that is `76`
    
    
    When I call {A.update_with_block} with `{ word_wrap: 80, code_indent: 8 }`
    
    Then the response is a {NRSER::Text::Renderer::Options}
    And it is NOT `A.default_options`
    And it has a `word_wrap` attribute that is `72`
  
  
  Scenario: (3) Using {#apply} to create modified versions
    
    Given a module:
      """ruby
      module A
        
        def self.default_options
          @options ||= NRSER::Text::Renderer::Options.new
        end
        
        
        def self.f options = nil
          options = default_options.merge options
          
          if options.word_wrap != false
            options = options.apply :word_wrap, :-, options.code_indent
          end
          
          options
        end
        
      end
      """
      
    When I call {A.f} with `{ word_wrap: 80, code_indent: 4 }`
    
    Then the response is a {NRSER::Text::Renderer::Options}
    And it is NOT `A.default_options`
    And it has a `word_wrap` attribute that is `76`
  