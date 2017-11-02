module NRSER
  refine ::Symbol do
    
    def to_getter
      ->( gettable ) { gettable[self] }
    end
    
  end # refine ::Symbol
end # NRSER
