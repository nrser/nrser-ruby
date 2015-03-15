require 'spec_helper'

describe "NRSER.common_prefix" do
  it "raises an error if argument is empty" do
    expect{ NRSER.common_prefix [] }.to raise_error ArgumentError
  end

  it "works on a single string" do
    expect( NRSER.common_prefix ['']    ).to eq ''
    expect( NRSER.common_prefix ['aaa'] ).to eq 'aaa'
  end

  it "works on a simple example" do
    expect( NRSER.common_prefix ['aaa', 'acb', 'abc'] ).to eq 'a'
  end

  it "works when the strings are all the same" do
    expect( NRSER.common_prefix ['aaa', 'aaa', 'aaa'] ).to eq 'aaa'
  end

  it "finds indents" do
    expect(
      NRSER.common_prefix <<-BLOCK.lines
        def f x
          x * x
        end
      BLOCK
    ).to eq "        "
  end
end # common_prefix
