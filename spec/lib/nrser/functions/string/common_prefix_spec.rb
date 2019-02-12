require 'nrser/strings'

SPEC_FILE(
  spec_path:        __FILE__,
  method:           'NRSER::Strings.common_prefix',
) do

  CASE "raises an error if argument is empty" do
    CALLED_WITH [] do
      it { expect { subject }.to raise_error ArgumentError }
    end
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
  
  it "finds indents in %-quoted strings" do
    str = %|
      hey
      there
    |.lines.reject { |s| s.n_x.whitespace? }.join
    
    expect( NRSER.common_prefix str.lines ).to eq '      '
  end

end # SPEC_FILE
