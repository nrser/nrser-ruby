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

# Describe a method of the parent subject.
# 
# @param [Method | Symbol | String] method
#   The method being described:
#   
#   1.  {Method} instance - used directly.
#       
#   2.  {Symbol}, {String} - 
# 
# @return [void]
# 
def describe_method method,
                    *description,
                    bind_subject: nil,
                    **metadata,
                    &body
  case method
  when Method
    method_name = method.name
    subject_block = -> { method }
    bind_subject = true
    name_string = NRSER::RSpex::Format.md_code_quote \
      "#{ method.receiver }.#{ method.name }"
  
  when Symbol, String
    method_name = method

    # Due to legacy, we only auto-bind if the name is a symbol
    # 
    # TODO  Get rid of this
    # 
    bind_subject = method_name.is_a?( Symbol ) if bind_subject.nil?

    subject_block = if bind_subject
      -> { super().method method_name }
    end

    name_prefix = if  self.respond_to?( :metadata ) &&
                      self.metadata.key?( :constructor_args )
      '#'
    else
      '.'
    end
  
    method = if self.try( :metadata )
      getter = if self.metadata.key?( :constructor_args )
        :instance_method
      else
        :method
      end
      
      target = self.metadata[:class] || self.metadata[:module]
      
      if target
        begin
          target.public_send getter, method_name
        rescue
          nil
        end
      end
    end
  
    name_string = NRSER::RSpex::Format.md_code_quote \
      "#{ name_prefix }#{ method_name }"
  
  else
    raise NRSER::TypeError.new \
      "Expected Method, Symbol or String for `method_name`, found",
      method_name
    
  end # case method_arg
  
  # Create the RSpec example group context
  describe_x \
    name_string,
    NRSER::Meta::Source::Location.new( method ),
    *description,
    type: :method,
    metadata: {
      **metadata,
      method_name: method_name,
    },
    bind_subject: bind_subject,
    subject_block: subject_block,
    &body
end # #describe_method

alias_method :METHOD, :describe_method


# /Namespace
# ========================================================================

end # module Describe
end # module ExampleGroup
end # module RSpex
end # module NRSER
