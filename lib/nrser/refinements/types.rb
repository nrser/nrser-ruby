module NRSER
  module Types
    refine Object do
      def t
        NRSER::Types
      end
      
      def to_type
        NRSER::Types.make self
      end
    end
  end # module Types
end # module NRSER
