require 'spec_helper'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types

describe NRSER::Message, type: :class do
  
  describe "#to_proc" do
        
    describe_section "mapping an Enumerable using &message" do
      subject { ->( message ) { enum.map &message } }
      
      context_where enum: [ [], [1], [1, 2] ] do
        let( :enum ) { [ [], [1], [1, 2] ] }
        
        describe_called_with NRSER::Message.new( :length ) do
          it { is_expected.to eq [0, 1, 2] }
        end # called with 
        
        describe_called_with NRSER::Message.new( :first ) do
          it { is_expected.to eq [nil, 1, 1] }
        end # called with :first
        
      end # enum 
      
    end # mapping an Enumerable
    
  end # #to_proc
  
end # NRSER::Message, type: :class
