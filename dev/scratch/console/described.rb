require 'nrser/meta/names'

Names = NRSER::Meta::Names

require 'nrser/described/cucumber/parameter_types'

ParameterTypes = NRSER::Described::Cucumber::ParameterTypes

require 'nrser/described/cucumber/tokens'

Tokens = NRSER::Described::Cucumber::Tokens

class Proc
  def _dump level
    object_id.to_s
  end
  
  def self._load dump
    ObjectSpace._id2ref dump.to_i
  end
end
