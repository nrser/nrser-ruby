SPEC_FILE(
  spec_path:        __FILE__,
  class:            NRSER::AttrError,
) do
  
  METHOD '#default_message' do
  # ==========================================================================

    SETUP "create an", NRSER::AttrError,
          "from the `keys` slice of `all_values` and call #default_message" do
      
      let :all_values do
        { 
          value: 'hey',
          name: :empty?,
          expected: true,
          actual: false,
        }
      end

      subject do
        described_class.new( all_values.slice( *keys ) ).default_message
      end

      WHEN keys: [ :value, :name, :expected, :actual ] do
        it do
          is_expected.to eq ~%{
            String object "hey" has invalid #empty? attribute,
            expected true, found false
          }; end; end
      
      WHEN keys: [] do
        it ~%{ defers to the super method } do
          is_expected.to eq "(no message)"; end; end
      
      WHEN keys: [ :value ] do
        it ~%{ defers to the super method } do
          is_expected.to eq "(no message)"; end; end

      WHEN keys: [ :name ] do
        it ~%{ defers to the super method } do
          is_expected.to eq "(no message)"; end; end
      
      WHEN keys: [ :value, :name ] do      
        it ~%{  renders the "name and value" part, and also the "found" part 
                because it will send the name to the value to get it } do
          is_expected.to eq ~%{
            String object "hey" has invalid #empty? attribute, found false
          }; end; end
      
      WHEN keys: [ :expected ] do
        it ~%{ renders just the "expected" part } do
          is_expected.to eq ~%{ expected true }; end; end
      
      WHEN keys: [ :actual ] do
        it ~%{ render just the "found" part } do
          is_expected.to eq ~%{ found false }; end; end
      
      WHEN keys: [ :actual, :expected ] do
        it ~%{ renders "expected" and "found" parts } do
          is_expected.to eq ~%{ expected true, found false }; end; end
    
    end # SETUP
    
  end # METHOD '#default_message' ********************************************
  

end # SPEC_FILE