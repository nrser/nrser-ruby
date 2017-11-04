module NRSER
  refine ::Symbol do
    
    # See {NRSER.retriever}.
    def to_retriever
      NRSER.retriever self
    end
    
    alias_method :retriever, :to_retriever
    alias_method :rtvr, :to_retriever
    
    
    # Alias 'sender' methods to built-in {#to_proc} so symbols can behave like
    # arrays in this way
    alias_method :to_sender,  :to_proc
    alias_method :sender,     :to_sender
    alias_method :sndr,       :to_sender
    
  end # refine ::Symbol
end # NRSER
