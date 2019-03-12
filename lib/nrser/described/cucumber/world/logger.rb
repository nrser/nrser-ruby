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

# Provide logging methods with a *reasonable* logger name in Cucumber "step 
# classes".
# 
module Logger
  
  include NRSER::Log::Mixin::SingletonMethods
  
  # Give a more reasonable-length name for the damn thing.
  # 
  # @return [::String]
  # 
  def to_short_s
    "#<Object+Cucumber::Glue::ProtoWorld+...:0x#{ object_id.to_s( 16 ) }>"
  end
  
  
  protected
  # ========================================================================
    
    # Get a logger for this instance with a {#to_short_s} name.
    # 
    # @return [NRSER::Log::Logger]
    # 
    def create_logger
      NRSER::Log[ to_short_s ]
    end
    
  public # end protected ***************************************************
  
end # module Logger


# /Namespace
# =======================================================================

end # module World
end # module Cucumber
end # module Described
end # module NRSER
