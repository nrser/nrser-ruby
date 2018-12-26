module NRSER
  module Types
    refine ::Object do
      def t *args
        if args.empty?
          NRSER::Types
        else
          NRSER::Types.make *args
        end
      end
      
      def to_type
        NRSER::Types.make self
      end
    end
  end # module Types
end # module NRSER
