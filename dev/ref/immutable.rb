# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------

# Deps
# -----------------------------------------------------------------------

# Project / Package
# -----------------------------------------------------------------------
require_relative './storage/key'
require_relative './storage/instance_variable'


# Declarations
# =======================================================================

module NRSER; end
module NRSER::Props; end


# Definitions
# =======================================================================

module NRSER::Props::Immutable
  
  KEY_STORAGE = NRSER::Props::Storage::Key.new immutable: true
  
  INSTANCE_VARIABLE_STORAGE = \
    NRSER::Props::Storage::InstanceVariable.new sub_storage: KEY_STORAGE
  
  
  # Class Methods
  # ======================================================================
  
  def self.included base
    base.include NRSER::Props
    base.metadata.storage INSTANCE_VARIABLE_STORAGE
    base.metadata.freeze
  end
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Props::Immutable::Vector`.
  def initialize source = {}
    values = {}
    
    self.class.props( only_primary: true ).values.each do |prop|
      values[prop.key] = prop.create_value self, source
    end
    
    instance_variable_set self.class.metadata.storage.var_name,
                          Hamster::Hash.new( values )
  end # #initialize
  
  
  # @todo Prob wanna improve this at some point, but it's better than nothing.
  # 
  # @return [String]
  #   a short string describing the instance.
  # 
  def to_s
    props_str = self.class.props( only_primary: true ).sort.map { |name, prop|
      "#{ name }=#{ prop.get( self ).inspect }"
    }.join ' '
    
    <<-END.squish
      #<#{ self.class.name } #{ props_str }>
    END
  end # #to_s
end # module NRSER::Props::Immutable
