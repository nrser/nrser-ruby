require 'nrser/strings/common_prefix'

# Using {String#whitespace?}
require 'nrser/ext/string'
using NRSER::Ext::String

SPEC_FILE(
  spec_path:        __FILE__,
  method:           'NRSER::Strings.common_prefix',
) do

  CASE "raises an error if argument is empty" do
    CALLED_WITH [] do
      it { expect { subject }.to raise_error ArgumentError } end
  end

  CASE "works on a single string" do
    CALLED_WITH [ '' ] do
      it { is_expected.to eq '' } end
    
    CALLED_WITH [ 'aaa' ] do
      it { is_expected.to eq 'aaa' } end
  end

  CASE "works on a simple example" do
    CALLED_WITH ['aaa', 'acb', 'abc'] do
      it { is_expected.to eq 'a' } end
  end

  CASE "works when the strings are all the same" do
    CALLED_WITH ['aaa', 'aaa', 'aaa'] do
      it { is_expected.to eq 'aaa' } end
  end

  CASE "finds indents" do
    lines = <<-BLOCK.lines
        def f x
          x * x
        end
      BLOCK
    
    CALLED_WITH lines do
      it { is_expected.to eq (' ' * 8) } end
  end
  
  CASE "finds indents in %-quoted strings" do
    lines = %%
      hey
      there
    %.lines.reject { |s| s.whitespace? }
    
    CALLED_WITH lines do
      it { is_expected.to eq (' ' * 6) } end
  end

end # SPEC_FILE
