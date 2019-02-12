require 'nrser/ext/array'

require 'nrser/refinements/types'
using NRSER::Types


CLASS NRSER::Message do
  
  INSTANCE_METHOD "#to_proc" do
        
    CASE "mapping an Enumerable using &message" do
      
      subject { ->( message ) { enum.map &message } }
      
      WHEN enum: [ [], [1], [1, 2] ] do
        
        CALLED_WITH NRSER::Message.new( :length ) do
          it { is_expected.to eq [0, 1, 2] }
        end # called with
        
        CALLED_WITH NRSER::Message.new( :first ) do
          it { is_expected.to eq [nil, 1, 1] }
        end # called with :first
        
      end # enum
      
    end # mapping an Enumerable using &message
    
  end # #to_proc
  
  
  CASE "Refinements" do
  # ========================================================================
    
    describe "Array#to_message" do
      
      subject { array.n_x.to_message }
      
      WHEN array: [:fetch, :x] do
        it {
          is_expected.to be_a( NRSER::Message ).and have_attributes \
              symbol: :fetch,
              args:   [:x],
              block:  nil
        }
        
        METHOD :send_to do
          CALLED_WITH x: 'ex', y: 'why?' do
            it { is_expected.to eq 'ex' }
          end
        end
        
      end # array: [:fetch, :x]
      
    end # Array#to_message
    
    
  end # CASE Refinements
  # ************************************************************************
  
  
end # NRSER::Message, type: :class
