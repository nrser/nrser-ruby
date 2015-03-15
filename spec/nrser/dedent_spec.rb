require 'spec_helper'

describe "NRSER.dedent" do
  it "removes indents" do
    expect(
      NRSER.dedent <<-BLOCK
        def f x
          x * x
        end
      BLOCK
    ).to eq <<-BLOCK
def f x
  x * x
end
BLOCK
  end

  it "ignores things it that aren't indented" do
    expect(
      NRSER.dedent <<-BLOCK
def f x
  x * x
end
BLOCK
    ).to eq <<-BLOCK
def f x
  x * x
end
BLOCK
  end

  it "handles edge cases" do
    expect( NRSER.dedent ''     ).to eq ''
    expect( NRSER.dedent 'blah' ).to eq 'blah'
  end
end