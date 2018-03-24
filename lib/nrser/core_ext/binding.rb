require_relative './string'
require_relative './enumerable'

# Extension methods for {Binding}
# 
class Binding
  
  # Calls {NRSER.template} with `self` prepended to `*args`
  # 
  # @param (see NRSER.erb)
  # @return (see NRSER.erb)
  # 
  def erb source
    require 'erb'
    
    NRSER.filter_repeated_blank_lines(
      NRSER.with_indent_tagged( NRSER.dedent( source ) ) { |tagged_str|
        ERB.new( tagged_str ).result( self )
      },
      remove_leading: true
    )
  end
  
  alias_method :template, :erb
  
  
  # Get a {Hash} of all local variable names (as {Symbol}) to values.
  # 
  # @return [Hash<Symbol, Object>]
  # 
  def locals
    self.local_variables.assoc_to { |symbol| bnd.local_variable_get symbol }
  end
  
  
  # Get a {Array} of all local variable values.
  # 
  # @return [Array<Object>]
  # 
  def local_values
    self.local_variables.map { |symbol| bnd.local_variable_get symbol }
  end
  
end # class Binding
