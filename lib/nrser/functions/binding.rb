module NRSER
  def self.erb bnd, str
    require 'erb'
    
    filter_repeated_blank_lines(
      with_indent_tagged( dedent( str ) ) { |tagged_str|
        ERB.new( tagged_str ).result( bnd )
      },
      remove_leading: true
    )
  end # erb
  
  singleton_class.send :alias_method, :template, :erb
  
  
  # Get a {Hash} of all local variable names (as {Symbol}) to values.
  # 
  # @param [Binding] bnd
  #   Binding to get locals from.
  # 
  # @return [Hash<Symbol, Object>]
  # 
  def self.locals bnd
    NRSER.map_values( bnd.local_variables ) { |symbol, _|
      bnd.local_variable_get symbol
    }
  end # .locals
  
  
  # Get a {Array} of all local variable values.
  # 
  # Written to facilitate checks like "all argument values are not `nil`".
  # 
  # @param [Binding] bnd
  #   Binding to get locals from.
  # 
  # @return [Array<Object>]
  # 
  def self.local_values bnd
    bnd.local_variables.map { |symbol| bnd.local_variable_get symbol }
  end # .locals
  
end # module NRSER
