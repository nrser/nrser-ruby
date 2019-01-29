require 'i8'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           Hamster,
) do
  
  SETUP %{
    Converting I8 to regular structures with their `#to_mutable`
  }.squish do
    
    it %{ gets immutable objects nested inside mutable ones } do
      
      # Because `I8({ x: 1 }) == { x: 1 }` (which is usually probably very nice
      # to have) we have to do more than just compare with `==`.
      # 
      # I *think* this accomplishes what we want...
      # 
      def class_match actual, expected
        return false unless actual == expected &&
                            actual.class == expected.class &&
                            actual.eql?( expected ) # This alone is prob
                                                    # enough...
        
        case expected
        when ::Hash, ::Array
          expected.each_branch do |key, expected_value|
            return false unless class_match( expected_value, actual[key] )
          end
        when ::Set
          expected.each do |expected_value|
            return false unless actual.include?( expected_value )
          end
        end
        
        true
      end
      
      expect(
        class_match(
          I8({ x: { y: I8({ z: 1 }) } }).to_mutable,
          { x: { y: { z: 1 } } }
        )
      ).to be true
      
      expect(
        class_match(
          I8({ x: { y: I8({ z: 1 }) } }).to_mutable,
          { x: { y: { z: 1 } } },
        )
      ).to be true
      
      expect(
        class_match(
          I8({ items: [ I8({ id: 1 }), I8({ id: 2 }) ] }).to_mutable,
          { items: [ { id: 1 }, {id: 2 } ] },
        )
      ).to be true
      
      expect(
        class_match(
          I8({ items: Set[ I8({ id: 1 }), I8({ id: 2 }) ] }).to_mutable,
          { items: Set[ { id: 1 }, {id: 2 } ] },
        )
      ).to be true
    end
  
  end # setup
  
  
  CLASS I8::Hash do
    describe_instance x: 1, y: 2, z: 3 do
      describe_method :to_mutable do
        CALLED do
          it { is_expected.to be_a( ::Hash ).and eq( {x: 1, y: 2, z: 3} ) }
        end
      end
    end
  end
  
  
  CLASS I8::Vector do
    describe_instance [1, 2, 3] do
      describe_method :to_mutable do
      CALLED do
          it { is_expected.to be_a( ::Array ).and eq [1, 2, 3] }
        end
      end
    end
  end
  
  
  CLASS I8::Set do
    describe_instance [1, 2, 3] do
      INSTANCE_METHOD :to_mutable do
        CALLED do
          it { is_expected.to be_a( ::Set ).and eq ::Set[1, 2, 3] }
        end
      end
    end
  end
  
  
  CLASS I8::SortedSet do
    describe_instance [1, 2, 3] do
      INSTANCE_METHOD :to_mutable do
        CALLED do
          it { is_expected.to be_a( ::SortedSet ).and eq ::SortedSet[1, 2, 3] }
        end
      end
    end
  end
  
end # Spec File Description
