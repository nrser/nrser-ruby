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
  
  
  def self.call_block bnd, *args, &block
    arg_count = 0
    arg_rest = false
    call_kwds = {}
    block.parameters.each do |type, name|
      logger.debug "Processing", type: type, name: name
      
      case type
      when :req, :opt
        arg_count += 1
      when :keyreq, :key
        if bnd.local_variable_defined? name
          call_kwds[name] = bnd.local_variable_get name
        end
      when :rest
        arg_rest = true
      end
    end
    
    call_args = if arg_rest
      args
    else
      args[0...arg_count]
    end
    
    logger.debug "CALLING WITH",
      args: call_args,
      kwds: call_kwds
    
    block.call *call_args, **call_kwds
  end
  
end # module NRSER
