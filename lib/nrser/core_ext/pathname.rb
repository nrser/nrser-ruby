require 'pathname'

class Pathname
  
  # override to accept Pathname instances.
  # 
  # @param [String] *prefixes
  #   the prefixes to see if the Pathname starts with.
  # 
  # @return [Boolean]
  #   true if the Pathname starts with any of the prefixes.
  # 
  def start_with? *prefixes
    to_s.start_with? *prefixes.map(&:to_s)
  end
  
  
  alias_method :_original_sub, :sub
  
  
  # override sub to support Pathname instances as patterns.
  # 
  # @param [String | Regexp | Pathname] pattern
  #   thing to replace.
  # 
  # @param [String | Hash] replacement
  #   thing to replace it with.
  # 
  # @return [Pathname]
  #   new Pathname.
  # 
  def sub pattern, replacement
    case pattern
    when Pathname
      _original_sub pattern.to_s, replacement
    else
      _original_sub pattern, replacement
    end
  end


  # Just returns `self`. Implemented to match the {String#to_pn} API so it
  # can be called on an argument that may be either one.
  # 
  # @return [Pathname]
  # 
  def to_pn
    self
  end
  
  
  # @todo Document find_root method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def find_up rel_path, **kwds
    NRSER.find_up rel_path, **kwds, from: self
  end # #find_root
  
  
  # @todo Document find_root method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def find_up! rel_path, **kwds
    NRSER.find_up! rel_path, **kwds, from: self
  end # #find_root
  
end # class Pathname
