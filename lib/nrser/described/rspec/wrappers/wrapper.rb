# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Wrappers


# Definitions
# =======================================================================

# Basically, a block that's going to be evaluated in a different environment.
# 
# In practical use, a block created in an *example group* that can only be 
# evaluated in an *example*.
#
class Wrapper
  def initialize description: nil, &block
    case description
    when Symbol
      @description = description.to_s
      
      if block
        raise ArgumentError,
          "Don't provide block with symbol"
      end
      
      if @description.start_with? '@'
        @block = Proc.new { instance_variable_get description }
      else
        @block = description.to_proc
      end
    else
      @description = description
      @block = block
    end
  end
  
  def unwrap context: nil
    if context
      context.instance_exec &@block
    else
      @block.call
    end
  end
  
  def to_s
    if @description
      @description.to_s
    else
      "#<Wrapper ?>"
    end
  end
  
  def inspect
    to_s
  end
end

# /Namespace
# =======================================================================

end # module  Wrappers
end # module  RSpec
end # module  Described
end # module  NRSER
