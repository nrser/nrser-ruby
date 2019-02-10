
if ENV[ 'NO_RSPEX' ]

MODULE NRSER::Described do

  CLASS NRSER::Described::Base do
    it { is_expected.to be_a ::Class }
    it { is_expected.to be ::NRSER::Described::Base }
    it { is_expected.to have_attributes name: "NRSER::Described::Base" }
    
    METHOD :error_type do
      it { is_expected.to be_a ::Method }
      
      ATTRIBUTE :name do
        it { is_expected.to be :error_type }
      end
      
      CALLED do
        it { is_expected.to be_a NRSER::Types::Type }
        it { is_expected.to be_a NRSER::Types::IsA }
        
        ATTRIBUTE :mod do
          it { is_expected.to be ::Exception }
        end
      end
    end
    
  end
  
end

CLASS ::Array do
  INSTANCE_METHOD '#to_s' do
    INSTANCE [ 1, 2, 3 ] do
      CALLED do
        it { is_expected.to eq '[1, 2, 3]' }
      end
    end
  end
end

end