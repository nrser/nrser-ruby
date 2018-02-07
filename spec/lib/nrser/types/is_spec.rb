require 'spec_helper'

describe NRSER::Types::Is do
  t = NRSER::Types
  
  describe '==' do 
    it "equates two different instances with equal types" do
      expect(t.is 1).to eq t.is(1)
      expect([t.is(1)]).to eq [t.is(1)]
    end
  end
end # NRSER::Types::Union