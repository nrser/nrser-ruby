using NRSER::Types

describe NRSER::Props do
  
  context "simple Point class" do
    
    # Setup
    # =====================================================================
    
    let(:point_class) {
      Class.new do
        include NRSER::Props::Immutable
        
        # So that error messages look right
        def self.name; 'Point'; end
        
        prop :x, type: t.int
        prop :y, type: t.int
        prop :blah, type: t.str, source: :blah
        
        def blah
          "blah!"
        end
      end
    }
    
    
    describe ".props" do
    # ========================================================================
      
      subject { point_class.props }
      
      it {
        is_expected.to be_a( Hash ).and have_attributes \
          keys: eq( [:x, :y, :blah] ),
          values: all( be_a NRSER::Props::Prop )
      }
      
      describe 'primary props `x` and `y`' do
        [:x, :y].each do |name|
          describe "prop `#{ name }`" do
            subject { super()[name] }
            
            include_examples "expect subject", to: {
              be_a: NRSER::Props::Prop,
              have_attributes: {
                source?: false,
                primary?: true,
              }
            }
          end
        end
      end # primary props `x` and `y`'
      
      describe "derived (sourced) prop `blah`" do
        subject { super()[:blah] }
        
        include_examples "expect subject", to: {
          be_a: NRSER::Props::Prop,
          have_attributes: {
            source?: true,
            primary?: false,
          }
        }
      end # derived (sourced) prop :blah
      
    end # .props
    
    # ************************************************************************
    
    
    describe ".props only_primary: true" do
    # ========================================================================
      
      subject { point_class.props only_primary: true }
      
      it {
        is_expected.to be_a( Hash ).
          and have_attributes(
            keys: eq( [:x, :y] ),
            values: all(
              be_a( NRSER::Props::Prop ).
                and have_attributes source?: false, primary?: true
            )
          )
      }
      
    end # .props only_primary: true
    
    # ************************************************************************
    
    describe "Point instance where x=1 and y=2 (default blah)" do
    # ========================================================================
      
      subject { point_class.new x: 1, y: 2 }
      
      it { is_expected.to have_attributes x: 1, y: 2, blah: "blah!" }
      
      describe "#to_h" do
        subject { super().to_h }
        it { is_expected.to eq x: 1, y: 2, blah: 'blah!' }
      end
      
      describe "#to_h only_primary: true" do
        subject { super().to_h only_primary: true }
        it { is_expected.to eq x: 1, y: 2 }
      end
      
      # ************************************************************************
      
    end # Point instance where x=1 and y=2 (default blah)
    
    # ************************************************************************
    
    
    describe "bad constructor args" do
    # ========================================================================
      
      it "rejects string `y: 'why?'` value" do
        expect { point_class.new x: 1, y: 'why?' }.to raise_error TypeError
      end
      
    end # bad constructor args
    
    
    describe ".new" do
      subject { point_class.method :new }
      
      it_behaves_like "function",
        mapping: {
          [{x: 1, y: 2}] => NRSER::Message.new(
            :have_attributes, x: 1, y: 2, blah: 'blah!'
          ),
        },
        raising: {
          [ {x: 1, y: 'why?'} ] => [
            TypeError,
            /Value of type String for prop Point\#y\s+failed type check/m
          ],
        }
    end # .new
    
    
    describe "dump / load cycle" do
      context "Point with x=1, y=2" do
        let( :point ) { point_class.new x: 1, y: 2 }
        let( :point_hash ) { point.to_h }
        
        describe "new Point from old point's #to_h" do
          subject { point_class.new point_hash }
          it { is_expected.to have_attributes x: 1, y: 2, blah: 'blah!' }
        end # new Point from old point's #to_h
      end
    end # dump / load cycle
    
  end # simple Point class
  
end # NRSER::Props::Props
