require 'spec_helper'
require 'nrser/refinements'

using NRSER

describe "NRSER.truncate" do
  it "refines String" do
    expect( "blah blah blah blah".truncate 10 ).to eq "blah bl..."
  end
end # indent
