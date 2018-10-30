# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup
module  Describe


# Definitions
# ========================================================================

# The core, mostly internal method that all RSpex's description methods lead
# back too (or should / will when refactoring is done).
# 
# Keyword options are explicitly broken out in this method, versus the sugary
# ones that call it, so `metadata` can be set without restriction (save the
# `type` key, which is also it's own keyword here). You can use this method
# if you want the RSpex functionality but absolutely have to set some
# metadata key that we use for something else.
# 
# @param [Array] description
#   Optional list of elements that compose the custom description.
#   
#   Will be passed to {NRSER::RSpex::Format.description} to produce the
#   string value that is in turn passed to {RSpec.describe}.
# 
# @param [Symbol] type
#   The RSpex "type" of the example group, which is used to determine the
#   prefix of the final description and is assigned to the `:type` metadata
#   key.
# 
# @param [Hash<Symbol, Object>] metadata
#   [RSpec metadata][] to add to the new example group.
#   
#   In addition to the keys RSpec will reject, we prohibit `:type` *unless*
#   it is the same as the `type` keyword argument or `nil`.
#   
#   In either of these cases, the `type` keyword arg will be used for the new
#   example group's `:type` metadata value.
#   
#   [RSpec metadata]: https://relishapp.com/rspec/rspec-core/docs/metadata/user-defined-metadata
# 
# @param [Hash<Symbol, Object>] bindings
#   Name to value pairs to bind in the new example group.
#   
#   All values will be bound at the example group and example levels -
#   though if they are {Wrapper}, that wrapper will be available at the
#   group level, while they will be automatically unwrapped at the
#   example level (as the requisite context is available there).
# 
# @param [Boolean] bind_subject
#   When `true` (and there is a `subject_block`) bind the `subject` inside
#   the new example group.
# 
# 
# @return [Class<RSpec::Core::ExampleGroup>]
#   The newly created {::Class}.
# 
def describe_x  *description,
                type:,
                metadata: {},
                bindings: {},
                add_binding_desc: true,
                bind_subject: true,
                subject_block: nil,
                &body
  
  # Check that `metadata` doesn't have a `:type` value too... although we
  # allow it if's equal to `type` or `nil` 'cause why not I guess?
  # 
  if  metadata.key?( :type ) &&
      metadata[:type] != nil &&
      metadata[:type] != type
    raise ArgumentError.new binding.erb <<-END
      `metadata:` keyword argument may not have a `:type` key that conflicts
      with the `type:` keyword argument.
      
      Received:
        `type`:
        
            <%= type.inspect %>
        
        `metadata[:type]`:
        
            <%= metadata[:type].pretty_inspect %>
      
    END
  end
  
  # Add description of the bindings, if we have any and were told to
  unless bindings.empty? || add_binding_desc == false
    bindings_desc =  NRSER::RSpex::Format.md_code_quote \
      bindings.map { |name, value|
        "#{ name } = #{ RSpex::Format::Description.string_for value }"
      }.join( '; ' )
    
    if description.empty?
      description = bindings_desc
    else
      description << "(" + bindings_desc + ")"
    end
  end

  x_description = RSpex::Format::Description.new *description, type: type
  
  # Call up to RSpec's `#describe` method
  describe(
    # NRSER::RSpex::Format.description( *description, type: type ),
    x_description,
    **metadata,
    x_description: x_description,
    type: type,
  ) do
    if subject_block && bind_subject
      subject &subject_block
    end
    
    # Bind bindings
    unless bindings.empty?
      bindings.each { |name, value|
        # Example-level binding
        let( name ) { unwrap value, context: self }
        
        # Example group-level binding (which may return a {Wrapper} that
        # of course can not be unwrapped at the group level)
        define_singleton_method( name ) { value }
      }
    end
    
    module_exec &body
  end # describe
  
end # #describe_x

alias_method :describe_x_type, :describe_x


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
