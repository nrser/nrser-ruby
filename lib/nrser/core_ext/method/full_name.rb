require_relative '../module/names'


class Method
  
  # Returns the method's {#receiver} and {#name} in the common
  # `A.cls_meth` / `A#inst_meth` format.
  # 
  def full_name
    case receiver
    when Module
      "#{ receiver.safe_name }.#{ name }"
    else
      "#{ receiver.class.safe_name }##{ name }"
    end
  end
  
  # Use full name as a {Method}'s "summary"
  alias_method :to_summary, :full_name
  
end # class Method
