# Extension methods for {String}
# 
module NRSER::Ext::String
  
  def squish
    NRSER.squish self
  end
  
  
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
  
end # module NRSER::Ext::String
