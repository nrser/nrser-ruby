require 'spec_helper'

require 'nrser/refinements'
using NRSER

describe "NRSER.each_branch" do
  
  subject { NRSER.method :each_branch }
  
  context "called without a block" do
    context "called with arrays" do
      describe_called_with( [] ) {
        it {
          is_expected.to be_a( Enumerator ).
            and have_attributes size: 0
        }
      }
      
      describe_called_with( [:x, :y, :z] ) {
        it {
          is_expected.to be_a( Enumerator ).
            and have_attributes size: 3
        }
      }
    end # called with arrays
    
    context "called with hashes" do
      describe_called_with( {} ) {
        it {
          is_expected.to be_a( Enumerator ).
            and have_attributes size: 0
        }
      }
    end # called with hashes
    
    context "convert returned Enumerator to array" do
      subject {
        # CRASHES VM!!!
        # ->( *args ) { super().call( *args ).to_a }
        ->( *args ) { NRSER.each_branch( *args ).to_a }
      }
      
      it_behaves_like 'function',
        mapping: {
          [ {x: 'ex', y: 'why?', z: 'zee!'} ] => [
            [:x, 'ex'],
            [:y, 'why?'],
            [:z, 'zee!'],
          ],
          
          [ [:x, :y, :z] ] => [
            [0, :x],
            [1, :y],
            [2, :z],
          ]
        }
    end # convert Enumerator to array
  end # called without a block
  
  context "called with a block" do
    
    context "called with arrays" do
      
      subject {
        input = [:x, :y, :z]
        result = {}
        super().call( input ) { |index, value|
          result[index] = value 
        }
        result
      }
      
      it {
        is_expected.to eq(0 => :x, 1 => :y, 2 => :z)
      }
      
    end # called with arrays
    
  end # called with a block
  
end # NRSER.each_branch

