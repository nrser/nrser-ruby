describe "NRSER.map_branches" do
# ========================================================================
  
  subject { NRSER.method :map_branches }
  
  context "called without a block" do
  # ========================================================================
    
    it "raises an error" do
      expect { subject.call [1, 2, 3] }.to raise_error ArgumentError
    end
    
  end # called without a block
  # ************************************************************************
  
  
  context "called with a block" do
  # ========================================================================
    
    context "called with arrays" do
    # ========================================================================
      
      context_where tree: [1, 2, 3] do
        context "square values" do
          subject {
            super().call( [1, 2, 3] ) { |index, value| [index, value * value] }
          }
          
          it { is_expected.to eq [1, 4, 9] }
        end # [1, 2, 3] => v * v
      end # tree: [1, 2, 3]
      
      
      context_where tree: [:a, :b] do
        context "swap values (totally contrived example)" do
          # Don't actually swap like this, but tests how I think it works
          
          subject {
            super().call( tree) { |index, value|
              [(index + 1) % 2, value]
            }
          }
          
          it { is_expected.to eq [:b, :a] }
        end # [1, 2, 3] => v * v
      end # tree: [:a, :b]
      
      
    end # called with arrays
    # ************************************************************************
    
    
    context "called with hashes" do
    # ========================================================================
      
      context_where tree: {x: 'ex', y: 'why?'} do
        
        describe "map keys to string #ord" do
          subject {
            super().call( tree ) { |key, value|
              [key.to_s.ord, value]
            }
          }
          
          it { is_expected.to eq 120 => 'ex', 121 => 'why?' }
        end
        
      end # tree: {x: 'ex', y: 'why?'}

      
    end # called with hashes
    # ************************************************************************
    
  end # called with a block
  # ************************************************************************
  
end # NRSER.map_branches
# ************************************************************************
