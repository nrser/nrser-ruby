# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require_relative './wrappers/wrapper'
require_relative './format'

# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec


# Definitions
# =======================================================================

# Module that gets included in the top-level scope inside `rspec` processes
# to make stuff globally available.
# 
module TopLevelMixin
  
  # Hook to include other modules.
  # 
  def self.included base
    # Make the example group extensions available at the top-level
    include ExampleGroup::Describe
  end

  
  Wrapper = Wrappers::Wrapper
  
  
  def wrap description = nil, &block
    if block
      Wrapper.new description: description, &block
    else
      Wrapper.new description: description.to_s do
        send description
      end
    end
  end
  
  
  def unwrap obj, context: nil
    if obj.is_a? Wrapper
      obj.unwrap context: context
    else
      obj
    end
  end
  
  
  def msg *args, &block
    NRSER::Message.from *args, &block
  end


  def List *args
    Format::List.new args
  end
  
  
  def Args *args
    Format::Args.new args
  end
  
end # module TopLevelMixin


# /Namespace
# =======================================================================

end # module  RSpec
end # module  Described
end # module  NRSER
