describe "NRSER.indent" do
  it "refines String to add indent" do
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

  it "accepts arguments to the refinement of String" do
    expect(
      <<-BLOCK.indent(4)
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
end # indent
