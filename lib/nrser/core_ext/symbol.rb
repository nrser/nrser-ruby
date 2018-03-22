class Symbol
  
  # See {NRSER.retriever}.
  def to_retriever
    NRSER.retriever self
  end
  
  
  # Alias 'sender' methods to built-in {#to_proc} so symbols can behave like
  # arrays in this way
  alias_method :to_sender,  :to_proc
  
end # NRSER
