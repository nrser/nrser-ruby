SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Booly,
) do
  
  TRUTHY_INPUTS = [
    'true', 'True', 'TRUE',
    'T', 't',
    'YES', 'yes', 'Yes',
    'Y', 'y',
    'ON', 'On', 'on',
    '1',
  ]

  FALSY_INPUTS = [
    'false', 'False', 'FALSE',
    'F', 'f',
    'NO', 'no',
    'N', 'n',
    'OFF', 'Off', 'off',
    '0',
    '',
  ]

  UNDECIDABLE_INPUTS = [
    'blah!',
  ]

  METHOD :truthy? do
  # ========================================================================

    context "strings" do
      context "true truthy strings" do
        TRUTHY_INPUTS.each do |string|
          it "recognizes string #{ string } as truthy" do
            expect(subject.call string).to be true
          end
        end
      end # true truthy strings
      
      context "false truthy strings" do
        FALSY_INPUTS.each do |string|
          it "recognizes string #{ string } as falsy" do
            expect(subject.call string).to be false
          end
        end
      end # false truthy strings
      
      context "undecidable truthy strings" do
        UNDECIDABLE_INPUTS.each do |string|
          it "errors on #{ string }" do
            expect{subject.call string}.to raise_error ArgumentError
          end
        end
      end # undecidable truthy strings
    end # strings

  end # METHOD :truthy? *****************************************************

  
  METHOD :falsy? do
  # ========================================================================
    
    CASE ~%{ {String} param } do
      
      WHEN ~%{ string represents `true` } do
        TRUTHY_INPUTS.each do |string|
          CALLED_WITH string  do it do is_expected.to be false
            end end end end

      WHEN ~%{ string represents `false` } do
        FALSY_INPUTS.each do |string|
          CALLED_WITH string do it do is_expected.to be true
            end end end end
      
      WHEN ~%{ string is undecidable } do
        UNDECIDABLE_INPUTS.each do |string|
          CALLED_WITH string do it do
            expect{ subject }.to raise_error ArgumentError
              end end end end
      
      end # CASE
    
  end # METHOD :falsy? *****************************************************
  
  
end # SPEC_FILE
