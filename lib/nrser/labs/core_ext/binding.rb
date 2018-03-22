class Binding
  
  # Experimental "adaptive" call from local variable names.
  # 
  def call_block *args, &block
    arg_count = 0
    arg_rest = false
    call_kwds = {}
    block.parameters.each do |type, name|
      logger.debug "Processing", type: type, name: name
      
      case type
      when :req, :opt
        arg_count += 1
      when :keyreq, :key
        if self.local_variable_defined? name
          call_kwds[name] = self.local_variable_get name
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
  
end # class Binding
