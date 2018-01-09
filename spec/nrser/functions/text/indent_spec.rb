require 'spec_helper'

describe "NRSER.indent" do
  it "indents a block" do
    expect(
      NRSER.indent <<-BLOCK
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

  it "indents a single line string" do
    expect( NRSER.indent "blah" ).to eq "  blah"
  end

end # indent
