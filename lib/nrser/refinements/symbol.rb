module NRSER
  refine ::Symbol do
    
    def to_retriever
      NRSER.retriever self
    end
    
    alias_method :retriever, :to_retriever
    alias_method :rtvr, :to_retriever
    
  end # refine ::Symbol
end # NRSER
