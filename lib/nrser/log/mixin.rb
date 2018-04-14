# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------


# Refinements
# =======================================================================


# Declarations
# =======================================================================


# Definitions
# =======================================================================


# @todo document NRSER::Log::Mixin module.
module NRSER::Log::Mixin
  
  def self.included base
      base.extend SemanticLogger::Loggable::ClassMethods
      base.class_eval do
        # Returns [SemanticLogger::Logger] class level logger
        def self.logger
          @semantic_logger ||= NRSER::Log[self]
        end

        # Replace instance class level logger
        def self.logger=(logger)
          @semantic_logger = logger
        end

        # Returns [SemanticLogger::Logger] instance level logger
        def logger
          @semantic_logger ||= self.class.logger
        end

        # Replace instance level logger
        def logger=(logger)
          @semantic_logger = logger
        end
      end
    end
  
end # module NRSER::Log::Mixin
