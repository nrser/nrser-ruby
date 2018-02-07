require 'spec_helper'

describe NRSER::Types::Union do
  t = NRSER::Types
  
  describe '==' do 
    it "equates two different instances with equal types" do
      expect(t.union 1, 2, 3).to eq t.union(1, 2, 3)
    end
  end
end # NRSER::Types::Union