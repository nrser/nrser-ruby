require 'nrser/ext/string'
using NRSER::Ext::String

INSTANCE_METHOD "NRSER::Ext::String#dedent" do
  
  let( :lines ) {
    [
      "def f x",
      "  x * x",
      "end",
      ""
    ]
  }
  
  let( :joined ) {
    lines.join("\n")
  }
  
  it "removes indents" do
    block =  <<-BLOCK
      def f x
        x * x
      end
    BLOCK
      
    expect( block.dedent ).to eq joined
  end

  it "ignores things it that aren't indented" do
    expect( joined.dedent ).to eq joined
  end

  it "handles edge cases" do
    expect( ''.dedent ).to eq ''
    expect( 'blah'.dedent ).to eq 'blah'
  end
  
  
  context "%-quoted multi-line string" do
    
    subject {
      %|
        def f x
          x * x
        end
      |
    }
    
    it {
      is_expected.to eq [
        "",
        "        def f x",
        "          x * x",
        "        end",
        "      ",
      ].join( "\n" )
    }
    
    describe "#lines" do
      subject { super().lines }
      it { is_expected.to eq [
        "\n",
        "        def f x\n",
        "          x * x\n",
        "        end\n",
        "      ",
      ] }
    end # #lines
    
    
    describe "dedent applied" do
      subject { super().dedent }
      
      it { is_expected.to eq "\n" + joined }
    end # "dedent"
    
    
  end # %-quoted multi-line strings
  
end