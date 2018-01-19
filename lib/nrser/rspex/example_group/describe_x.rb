# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # The core, mostly internal method that all RSpex's description methods lead
  # back too (or should / will when refactoring is done).
  # 
  # Keyword options are explicitly broken out in this method, versus the sugary
  # ones that call it, so `metadata` can be set without restriction (save the
  # `type` key, which is also it's own keyword here). You can use this method
  # if you want the RSpex functionality but absolutely have to set some
  # metadata key that we use for something else.
  # 
  # @param [Array] *description
  #   Optional list of elements that compose the custom description.
  #   
  #   Will be passed to {NRSER::RSpex::Format.description} to produce the
  #   string value that is in turn passed to {RSpec.describe}.
  # 
  # @param [Symbol] type:
  #   The RSpex "type" of the example group, which is used to determine the
  #   prefix of the final description and is assigned to the `:type` metadata
  #   key.
  # 
  # @param [Hash<Symbol, Object>] metadata:
  #   Metadata to add to the new example group.
  #   
  #   In addition to the keys RSpec will reject, we prohibit `:type` *unless*
  #   it is the same as the `type` keyword argument or `nil`.
  #   
  #   In either of these cases, the `type` keyword arg will be used for the new
  #   example group's `:type` metadata value.
  # 
  # @param [Hash<Symbol, Object>] bindings:
  #   
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def describe_x  *description,
                  type:,
                  metadata: {},
                  bindings: {},
                  add_binding_desc: true,
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
    
    unless bindings.empty? || add_binding_desc == false
      # bindings_desc = NRSER::RSpex::Opts[bindings].to_desc
      bindings_desc = ["(", bindings.ai( multiline: false ), ")"]
      
      if description.empty?
        description = bindings.ai( multiline: false )
      else
        description += ["(", bindings.ai( multiline: false ), ")"]
      end
    end
    
    formatted = NRSER::RSpex::Format.description *description, type: type
    
    describe formatted, **metadata, type: type do
      subject( &subject_block ) if subject_block
      
      unless bindings.empty?
        bindings.each { |name, value|
          let( name ) { unwrap value, context: self }
        }
      end
      
      module_exec &body
    end # description,
    
  end # #describe_x
  
  alias_method :describe_x_type, :describe_x
  
  
end # module NRSER::RSpex::ExampleGroup
