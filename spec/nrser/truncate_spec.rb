require 'spec_helper'

describe "NRSER.truncate" do
  it "truncates a string that's longer than length" do
    expect( NRSER.truncate "blah blah blah blah", 10 ).to eq "blah bl..."
  end

  it "leaves a string alone that's shorter or equal to lenght" do
    expect( NRSER.truncate "blah", 10 ).to eq "blah"
  end
end # indent
