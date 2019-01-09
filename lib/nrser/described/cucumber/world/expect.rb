# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber
module  World


# Definitions
# =======================================================================

# Helper method mixins for creating RSpec expectations from the descriptions.
# 
module Expect
  
  # Create an RSpec expectation for {#described}'s {Base#subject}.
  # 
  # @note
  #   This will trigger subject resolution on the description instance if the
  #   subject is not already resolved.
  # 
  # @return [RSpec::Expectations::ExpectationTarget]
  # 
  def expect_it
    expect subject
  end
  
  
  # Find the nearest description instance that's class has a provided "human
  # name", and create an RSpec expectation for it's {Base#subject}.
  # 
  # @note
  #   This will trigger subject resolution on the found description instance if 
  #   its subject is not already resolved.
  # 
  # @example Expect the nearest {NRSER::Described::Method}
  #   expect_described "method"
  # 
  # @param [::String] human_name
  #   A {NRSER::Described::Base.human_name} for the desired
  #   {NRSER::Described::Base} subclass.
  # 
  # @return [RSpec::Expectations::ExpectationTarget]
  # 
  def expect_described described
    if described.is_a? ::String
      described = hierarchy.find_by_human_name! described
    end
    
    expect described.resolve!( hierarchy ).subject
  end
  
end # module Expect


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
