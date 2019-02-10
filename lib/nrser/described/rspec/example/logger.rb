# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ============================================================================

### Project / Package ###

require 'nrser/log'


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Example


# Definitions
# =======================================================================

# Add {NRSER::Log} logging support to examples (which are example group class
# instances).
# 
module Logger

  # Proxies to {NRSER::RSpec::ExampleGroup::Logger#logger_named_tags}. Exposed
  # as an override point if needed.
  # 
  # @return [::Hash<#to_s, #to_s>]
  # 
  def logger_named_tags
    self.class.logger_named_tags
  end
  

  # The main API method - get the {NRSER::Log::Logger} for this example.
  # 
  # Check out {NRSER::RSpec::ExampleGroup::Logger#logger} for more info.
  # 
  # @return [NRSER::Log::Logger]
  # 
  def logger
    @semantic_logger ||= NRSER::Log[
      'RSpec::Examples',
      named_tags: logger_named_tags,
    ]
  end # #logger
  
end # module Logger


# /Namespace
# =======================================================================

end # module Example
end # module RSpec
end # module Described
end # module NRSER
