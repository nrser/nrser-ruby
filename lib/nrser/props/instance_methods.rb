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

module NRSER::Props; end


# Definitions
# =======================================================================

# @todo document NRSER::Props::ClassMethods module.
module NRSER::Props::InstanceMethods
  
  # Initialize the properties from a hash.
  # 
  # Called from `#initialize` in {NRSER::Props::Base}, but if you just
  # mix in {NRSER::Props::Props} you need to call it yourself.
  # 
  # @param [Hash<(String | Symbol) => Object>] values
  #   Property values. Keys will be normalized to symbols.
  # 
  # @return [nil]
  # 
  # def initialize_props source_values
  #   array = []
  #   hash = {}
  # 
  #   self.class.props(only_primary: true).values.each { |prop|
  #     value = prop.create_value self, source_values
  #     case prop.key
  #     when Integer
  #       array[key] = value
  #     when Symbol
  #       hash[key] = value
  #     else
  #       raise "SHOULD NEVER HAPPEN, prop.key: #{ prop.pretty_inspect }"
  #     end
  #   }
  # 
  #   # TODO  Now trigger all eager defaults (check prop getting trigger
  #   #       correctly)
  # 
  #   # Check additional type invariants
  #   self.class.invariants.each do |type|
  #     type.check self
  #   end
  # 
  #   nil
  # end # #initialize_props
  
  
  def merge overrides = {}
    self.class.new(
      self.to_h(only_primary: true).merge(overrides.symbolize_keys)
    )
  end
  
  
  # Create a new hash with property names mapped to values.
  # 
  # @param [Boolean] only_own:
  #   When `true`, don't include parent properties.
  # 
  # @param [Boolean] only_primary:
  #   When `true`, don't include sourced properties.
  # 
  # @return [Hash<Symbol, Object>]
  #   Map of prop names to values.
  # 
  def to_h only_own: false, only_primary: false
    self.class.
      props(only_own: only_own, only_primary: only_primary).
      transform_values { |prop| prop.get self }
  end # #to_h
  
  
  # Create a "data" representation suitable for transport, storage, etc.
  # 
  # The result is meant to consist of only basic data types and structures -
  # strings, numbers, arrays, hashes, datetimes, etc... though it depends on
  # any custom objects it encounters correctly responding to `#to_data` for
  # this to happen (as is implemented from classes that mix in Props here).
  # 
  # Prop names are converted to strings (from symbols) since though YAML
  # supports symbol values, they have poor portability across languages,
  # and they mean the same thing in this situation.
  # 
  # @param [Boolean] only_own:
  #   When `true`, don't include parent properties.
  # 
  # @param [Boolean] only_primary:
  #   When `true`, don't include sourced properties.
  # 
  # @param [Boolean] add_class:
  #   Add a special key with the class' name as the value.
  # 
  # @param [String] class_key:
  #   Name for special class key.
  # 
  # @return [Hash<String, Object>]
  #   Map of property names as strings to their "data" value, plus the special
  #   class identifier key and value, if requested.
  # 
  def to_data only_own: false,
              only_primary: false,
              add_class: true,
              class_key: '__class__'
              # class_key: NRSER::Props::DEFAULT_CLASS_KEY
              
    self.class.props(only_own: false, only_primary: false).
      map { |name, prop|
        [name.to_s, prop.to_data(self)]
      }.
      to_h.
      tap { |hash|
        hash[class_key] = self.class.name if add_class
      }
  end # #to_data
  
  
  # Language Inter-Op
  # ---------------------------------------------------------------------
  
  # Get a JSON {String} encoding the instance's data.
  # 
  # @param [Array] *args
  #   I really don't know. `#to_json` takes at last one argument, but I've
  #   had trouble finding a spec for it :/
  # 
  # @return [String]
  # 
  def to_json *args
    to_data.to_json *args
  end # #to_json
  
  
  # Get a YAML {String} encoding the instance's data.
  # 
  # @param [Array] *args
  #   I really don't know... whatever {YAML.dump} sends to it i guess.
  # 
  # @return [String]
  #   
  def to_yaml *args
    to_data.to_yaml *args
  end
  
end # module NRSER::Props::ClassMethods
