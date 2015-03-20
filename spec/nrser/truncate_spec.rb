require 'spec_helper'

using NRSER

describe "NRSER.truncate" do
  it "truncates a string that's longer than length" do
    expect( NRSER.truncate "blah blah blah blah", 10 ).to eq "blah bl..."
  end

  it "leaves a string alone that's shorter or equal to lenght" do
    expect( NRSER.truncate "blah", 10 ).to eq "blah"
  end

  it "refines String" do
    expect( "blah blah blah blah".truncate 10 ).to eq "blah bl..."
  end
end # indent
