require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


describe NRSER::Meta::Props do
  
  context "simple Point class" do
    
    # Setup
    # =====================================================================
    
    let(:point_class) {
      Class.new(NRSER::Meta::Props::Base) do
        # include NRSER::Meta::Props
        
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
          values: all( be_a NRSER::Meta::Props::Prop )
      }
      
      describe 'primary props `x` and `y`' do
        [:x, :y].each do |name|
          describe "prop `#{ name }`" do
            subject { super()[name] }
            
            include_examples "expect subject", to: {
              be_a: NRSER::Meta::Props::Prop,
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
          be_a: NRSER::Meta::Props::Prop,
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
              be_a( NRSER::Meta::Props::Prop ).
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
      # ========================================================================
        
        subject { super().to_h }
        
        it { is_expected.to be_a Hash }
        
      end # #to_h
      
      # ************************************************************************
      
      
    end # Point instance where x=1 and y=2 (default blah)
    
    # ************************************************************************
    
        
  end # simple Point class
  
  
  # it "has the props" do
  #   
  #   expect(p.to_h).to eq({x: 1, y: 2, blah: "blah!"})
  #   expect(p.to_h(only_primary: true)).to eq({x: 1, y: 2})
  #   
  #   expect { point.new x: 1, y: 'why?' }.to raise_error TypeError
  #   expect { p.x = 3 }.to raise_error NoMethodError
  #   
  #   p_hash = p.to_h
  #   
  #   p2 = point.new p_hash
  #   
  #   expect(p2.x).to be 1
  #   expect(p2.y).to be 2
  #   
  #   expect(p2.to_h).to eq({x: 1, y: 2, blah: "blah!"})
  # end
  
end # NRSER::Meta::Props

