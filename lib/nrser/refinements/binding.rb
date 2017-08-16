module NRSER
  refine Binding do
    def erb str
      NRSER.template self, str
    end
  end  
end # NRSER
