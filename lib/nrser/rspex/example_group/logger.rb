# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup


# Definitions
# =======================================================================

def identifier
  unless respond_to?( :metadata ) && !metadata.nil?
    return self.n_x.safe_name
  end

  case metadata[ :type ]
  when :attribute
    "Attribute<##{ metadata[ :attribute_name ] }>"
  when :called_with
    "CalledWith<#{ metadata[ :called_with_args ].to_desc }>"
  when :module
    "Module<#{ metadata[ :module ].n_x.safe_name }>"
  when :class
    "Class<#{ metadata[ :class ].n_x.safe_name }>"
  else
    self.name
  end
end


def super_identifier
  # Cut-off condition (any of):
  # 
  # 1.  No superclass
  #     
  # 2.  Superclass is not a proper subclass of {RSpec::Core::ExampleGroup},
  #     which causes us to cut off just before {RSpec::Core::ExampleGroup}
  #     when walking up the ancestor chain.
  # 
  if superclass.nil? || !( superclass < RSpec::Core::ExampleGroup )
    return nil 
  end

  if superclass.respond_to? :full_identifier
    superclass.full_identifier
  else
    superclass.n_x.safe_name
  end
end


def full_identifier
  if (super_identifier = self.super_identifier)
    "#{ super_identifier }::#{ identifier }"
  else
    identifier
  end 
end


def logger_name
  full_identifier
end


def logger
  @semantic_logger ||= NRSER::Log[ logger_name ]
end # #logger


# /Namespace
# =======================================================================

end # module ExampleGroup
end # module RSpex
end # module NRSER
