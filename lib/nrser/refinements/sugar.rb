# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

# Need {NRSER::MethodMissingForwarder}
require 'nrser/sugar/method_missing_forwarder'


# Definitions
# =======================================================================

# Some sugary sweet stuff that I find nice but seems irresponsible to
# monkey-patch in, so it's available as refinements.
# 
module NRSER::Sugar
  
  refine Object do
    
    # Get {Method} objects using concise syntax.
    # 
    # @example
    #   text = 'bee!'
    #   ['a', 'b', 'c'].any? { |char| text.meth.start_with? }
    # 
    # @return [NRSER::MethodMissingForwarder]
    #   That forwards `#method_missing( symbol )` to `self.method( symbol )`.
    # 
    def meth
      NRSER::MethodMissingForwarder.new do |symbol|
        self.method symbol
      end
    end
    
  end # refine Object
  
end # module NRSER::Sugar
