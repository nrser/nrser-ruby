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

# Namespace
# =======================================================================

module  NRSER
module  Described
module  Cucumber


# Definitions
# =======================================================================

# Hermann is a very bad marshal. The worst. Ever. In fact, what Hermann does is
# dump instances by just returning their `#object_id`, and loads by pulling it
# back out of {ObjectSpace} using {ObjectSpace#_id2ref}.
# 
#
# WTF..?
# ----------------------------------------------------------------------------
#
# It does this because, for some reason - that I have not had the time or heart
# to look into - Cucumber attempts to duplicate parameter values by first
# marshaling them, then un-marshaling them.
# 
# The relevant method is {Cucumber::StepMatch#deep_clone_args}, which you can 
# see here:
# 
# <https://github.com/cucumber/cucumber-ruby/blob/33632fc4efa6817d36479ea862235bf1bfccfa55/lib/cucumber/step_match.rb#L97>
#
# This *greatly* constrains what parameter types can be, because there are many
# things like {::Proc} and {::IO} and singleton objects that *can't* be
# marshaled.
#
# But this works. By totally circumventing whatever Cucumber is trying to do.
#
module Hermann
  
  # Extended into including classes.
  module ClassMethods
    def _load dump_string
      ::ObjectSpace._id2ref dump_string.to_i
    end
  end
  
  
  # The string representation of the `#object_id`.
  # 
  # @return [String]
  # 
  def _dump level
    object_id.to_s
  end
  
  
  def self.included base
    base.extend ClassMethods
  end
  
end # module Hermann


# /Namespace
# =======================================================================

end # module Cucumber
end # module Described
end # module NRSER
