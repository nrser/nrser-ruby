# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/described/base'


# Namespace
# =======================================================================

module  NRSER
module  Described


# Definitions
# =======================================================================

class Base
  
  def rspec_description *additional_description
    type = self.class.name.demodulize.underscore.to_sym
    
    content = if resolved? && subject?
      subject
    else
      described
    end
    
    Described::RSpec::Format::Description.new \
      content,
      *additional_description,
      type: type
  end
  
end # class Response


# /Namespace
# =======================================================================

end # module Described
end # module NRSER
