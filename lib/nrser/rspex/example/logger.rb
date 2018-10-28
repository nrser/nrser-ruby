# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Example


# Definitions
# =======================================================================

def logger_name
  self.class.full_identifier
end


def logger
  @semantic_logger ||= NRSER::Log[ logger_name ]
end # #logger


# /Namespace
# =======================================================================

end # module Example
end # module RSpex
end # module NRSER
