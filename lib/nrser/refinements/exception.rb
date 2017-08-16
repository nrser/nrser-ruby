module NRSER
  refine Exception do
    def format
      NRSER.format_exception self
    end
  end
end # NRSER
