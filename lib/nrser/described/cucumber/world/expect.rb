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
  
  def expect_it
    expect described.subject
  end
  
  
  def expect_described human_name
    expect described.find_by_human_name!( human_name ).subject
  end
  
end # module Expect


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
