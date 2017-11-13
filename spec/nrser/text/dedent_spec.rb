require 'spec_helper'

describe_method "NRSER.dedent" do
  subject { NRSER.method :dedent }
  
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
    expect(
      NRSER.dedent <<-BLOCK
        def f x
          x * x
        end
      BLOCK
    ).to eq joined
  end

  it "ignores things it that aren't indented" do
    expect( NRSER.dedent joined ).to eq joined
  end

  it "handles edge cases" do
    expect( NRSER.dedent ''     ).to eq ''
    expect( NRSER.dedent 'blah' ).to eq 'blah'
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
      subject { NRSER.dedent super() }
      
      it { is_expected.to eq "\n" + joined }
    end # "dedent"
    
    
  end # %-quoted multi-line strings
  
end