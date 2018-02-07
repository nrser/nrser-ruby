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
        
        describe_called_with NRSER::Message.new( :length ) do
          it { is_expected.to eq [0, 1, 2] }
        end # called with 
        
        describe_called_with NRSER::Message.new( :first ) do
          it { is_expected.to eq [nil, 1, 1] }
        end # called with :first
        
      end # enum 
      
    end # mapping an Enumerable using &message
    
  end # #to_proc
  
  
  describe_section "Refinements" do
  # ========================================================================
    
    describe "Array#to_message" do
      
      subject { array.to_message }
      
      context_where array: [:fetch, :x] do
        it {
          is_expected.to be_a( NRSER::Message ).and have_attributes \
              symbol: :fetch,
              args:   [:x],
              block:  nil
        }
        
        describe_sent_to x: 'ex', y: 'why?' do
          it { is_expected.to eq 'ex' }
        end # sent to x: 1, y: 2
        
      end # array: [:fetch, :x]
      
    end # Array#to_message
    
    
  end # section Refinements
  # ************************************************************************
  
  
end # NRSER::Message, type: :class
