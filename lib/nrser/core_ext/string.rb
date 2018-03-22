require 'active_support/core_ext/string/filters'

# Extension methods for {String}
# 
class String
  
  def unblock
    NRSER.unblock self
  end
  
  
  def dedent
    NRSER.dedent self
  end
  
  
  def indent *args
    NRSER.indent self, *args
  end
  
  
  def truncate *args
    NRSER.truncate self, *args
  end
  
  
  # See {NRSER.constantize}
  def constantize
    NRSER.constantize self
  end
  
  alias_method :to_const, :constantize
  
  
  # @return [Pathname]
  #   Convert self into a {Pathname}
  # 
  def to_pn
    Pathname.new self
  end
  
  
  def whitespace?
    NRSER.whitespace? self
  end
  
  
  # Calls {NRSER.ellipsis} on `self`.
  def ellipsis *args
    NRSER.ellipsis self, *args
  end
  
  
  # Calls {NRSER.words} on `self`
  def words *args, &block
    NRSER::words self, *args, &block
  end
  
  
  # @!group Unicode Stylization
  # ==========================================================================
  
  # Calls {NRSER.u_italic} on `self`
  def u_italic
    NRSER.u_italic self
  end
  
  
  # Calls {NRSER.u_bold} on `self`
  def u_bold
    NRSER.u_bold self
  end
  
  
  # Calls {NRSER.u_bold_italic} on `self`
  def u_bold_italic
    NRSER.u_bold_italic self
  end
  
  
  # Calls {NRSER.u_mono} on `self`
  def u_mono
    NRSER.u_mono self
  end
  
  # @!endgroup Unicode Stylization
  
end # class String
