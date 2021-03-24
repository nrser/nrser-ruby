# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Deps ###

# Need {::Cucumber::Glue::DSL.register_rb_step_definition} to register
require 'cucumber/glue/dsl'

### Project / Package ###

# Using {Booly#truthy?} on {ENV} var for Pry debugging
require 'nrser/booly'

require_relative '../parameter_types/pointer'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  Steps


# Definitions
# =======================================================================

module Helpers
  
  # Register a step.
  #
  # `Given`, `When`, `Then`, `And`, etc. are all just aliases to the same method
  # internally ({::Cucumber::Glue::Dsl.register_rb_step_definition} in the end)
  # and can be used interchangeably so I don't bother with them.
  # 
  # @return [::Cucumber::Glue::StepDefinition]
  #   Newly constructed and registered step.
  #
  def Step pattern, options = {}, &body
    # Wrap the actual body in our own proc
    proc = ->( *values ) {
      # Dereference any {Pointer}s to their target values
      values.map! { |value|
        if value.is_a? ParameterTypes::Pointer
          value.target
        else
          value
        end
      }
      
      begin
        instance_exec *values, &body
        
      rescue SystemExit
        raise
        
      rescue Exception => error
        if NRSER::Booly.truthy? ENV[ 'NRSER_PRY' ]
          # Need to grab ref 'cause otherwise `binding` will be different of
          # course inside `values.each_with_index` block, defeating the point
          _binding = binding
          
          # Easy access to values as `v0`, `v1`, ...
          values.each_with_index { |value, index|
            _binding.local_variable_set "v#{ index }", value
          }
          
          # 'Cause Cuc' has shadowed regular puts and it's a PITA
          def puts *args; STDOUT.puts *args; end
          
          # Named this way so *hopefully* search for "binding.pry" still
          # finds it...
          _binding.pry
        end
        
        raise
        
      end # begin ... rescue ...
    }
    
    ::Cucumber::Glue::Dsl.register_rb_step_definition pattern, proc, options
  end
  
  
  def components
    @components ||= {}
  end
  
  
  def def_step_component name, expression, &transformer
    components[ name.to_sym ] = \
      StepComponent::Expression.new name, expression, &transformer
  end
  
  
  def def_step_component_variations name, *components
    components[ name.to_sym ] = \
      StepComponent::Variations.new name, *components
  end
  
  
  def def_steps *components, &block
    component = case components.length
    when 0
      raise ArgumentError.new \
        "Need to provide components"
    when 1
      components[ 0 ]
    else
      StepComponent::Sequence.new :anon, *components
    end
    
    component.each do |
  end
  
end # module Helpers

# /Namespace
# =======================================================================

end # module Steps
end # module Cucumber
end # module Described
end # module NRSER
