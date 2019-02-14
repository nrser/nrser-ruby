# frozen_string_literal: true
# encoding: UTF-8

require 'nrser/ext/elidable'

SPEC_FILE(
  spec_path:        __FILE__,
  instance_method:  'NRSER::Ext::Elidable#ellipsis',
) do
  
  CLASS ::String do
    INSTANCE "abcdefg" do
      CASE ~%% raises when max too short / omission too long % do  
        CALLED_WITH 3, omission: '...' do
          it { expect { subject }.to raise_error NRSER::ArgumentError } end
      
        CALLED_WITH 1 do
          it { expect { subject }.to raise_error NRSER::ArgumentError } end
      end
      
      CASE ~%% works with reasonable maxes % do
        CALLED_WITH 2 do
          it { is_expected.to eq "a…" } end
        
        CALLED_WITH 5 do
          it { is_expected.to eq "ab…fg" } end
        
        CALLED_WITH 5, omission: '...' do
          it { is_expected.to eq "a...g" } end
        
        CALLED_WITH 6 do
          it { is_expected.to eq "abc…fg" } end
      end
      
    end
  end # CLASS ::String
  
  
  CLASS ::Array do
    INSTANCE [ 'a', 'b', 'c', 'd', 'e', 'f', 'g' ] do
    
      CASE ~%% raises when max too short / omission too long % do  
        CALLED_WITH 1, omission: '...' do
          it { expect { subject }.to raise_error NRSER::ArgumentError } end
      
        CALLED_WITH 1 do
          it { expect { subject }.to raise_error NRSER::ArgumentError } end
      end
      
      CASE ~%% works with reasonable maxes % do
        CALLED_WITH 2 do
          it { is_expected.to eq ['a', '…'] } end
        
        CALLED_WITH 5 do
          it { is_expected.to eq [ 'a', 'b', '…', 'f', 'g' ] } end
        
        CALLED_WITH 5, omission: '...' do
          it { is_expected.to eq [ 'a', 'b', '...', 'f', 'g' ] } end
        
        CALLED_WITH 6 do
          it { is_expected.to eq ["a", "b", "c", '…', "f", "g"] } end
      end
    
    end
  end # CLASS ::Array
  
end # SPEC_FILE