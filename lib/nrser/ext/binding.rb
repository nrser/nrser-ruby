# Extension methods for {Binding}
# 
module NRSER::Ext::Binding
  
  # Calls {NRSER.template} with `self` prepended to `*args`
  # 
  # @param (see NRSER.erb)
  # @return (see NRSER.erb)
  # 
  def template *args
    NRSER.template self, *args
  end
  
  alias_method :erb, :template
  
  
  # Calls {NRSER.locals} with `self` prepended to `*args`
  # 
  # @param (see NRSER.locals)
  # @return (see NRSER.locals)
  # 
  def locals *args
    NRSER.locals self, *args
  end
  
  
  # Calls {NRSER.local_values} with `self` prepended to `*args`
  # 
  # @param (see NRSER.local_values)
  # @return (see NRSER.local_values)
  # 
  def local_values *args
    NRSER.local_values self, *args
  end
  
end # module NRSER::Ext::Binding
