require_relative '../module/names'


class UnboundMethod
  
  # Instance Methods
  # ========================================================================
  
  def full_name
    # Need to string parse {#to_s}?!
    raise NotImplementedError, "Haven't done this one yet"
  end
  
  alias_method :to_summary, :full_name
  
end # class Method
