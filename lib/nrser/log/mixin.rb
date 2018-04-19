# encoding: UTF-8
# frozen_string_literal: true

# Definitions
# =======================================================================

# Adaptation of {SemanticLogger::Loggable} mixin to use {NRSER::Log::Logger}
# instances from {NRSER::Log.[]}.
# 
# Like {SemanticLogger::Loggable} adds class and instance `logger` and
# `logger=` methods that create loggers on demand and store them in the
# `@semantic_logger` instance variables.
# 
module NRSER::Log::Mixin
  
  # Methods to mix into the including class.
  # 
  module ClassMethods
    # Returns [SemanticLogger::Logger] class level logger
    def logger
      @semantic_logger ||= NRSER::Log[ self ]
    end

    # Replace instance class level logger
    def logger= logger
      @semantic_logger = logger
    end
  end
  
  
  # Class Methods
  # ========================================================================
  
  def self.included base
    base.extend ClassMethods
    
    # Adds `.logger_measure_method`
    base.extend SemanticLogger::Loggable::ClassMethods
  end
  
  
  # Instance Methods
  # ========================================================================
  
  # Returns [SemanticLogger::Logger] instance level logger
  def logger
    @semantic_logger ||= self.class.logger
  end
  
  
  # Replace instance level logger
  def logger= logger
    @semantic_logger = logger
  end
  
end # module NRSER::Log::Mixin
