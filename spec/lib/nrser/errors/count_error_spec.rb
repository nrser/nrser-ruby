SPEC_FILE(
  spec_path:        __FILE__,
  class:            NRSER::CountError,
) do
  
  METHOD '#default_message' do
  # ==========================================================================

    SETUP "create an", NRSER::CountError,
          "from the `keys` slice of `all_values` and call #default_message" do
      
      let :all_values do
        { 
          value: [],
          expected: 1,
          actual: 0,
          count: 0,
        }
      end

      subject do
        described_class.new( all_values.slice( *keys ) ).default_message
      end

      WHEN keys: [ :value, :expected, :actual ] do
        it do
          is_expected.to eq ~%{
            Array object [] has invalid #count attribute, expected 1, found 0
          }; end; end

      WHEN keys: [ :value, :expected, :count ] do
        it do
          is_expected.to eq ~%{
            Array object [] has invalid #count attribute, expected 1, found 0
          }; end; end
    
    end # SETUP
    
  end # METHOD '#default_message' ********************************************
  

end # SPEC_FILE