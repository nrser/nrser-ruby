require 'nrser/ext/string'
using NRSER::Ext::String

INSTANCE_METHOD "NRSER::Ext::String#indent" do
  it "indents a block" do
    expect(
      <<-BLOCK.indent
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
    expect( "blah".indent ).to eq "  blah"
  end

end # indent
