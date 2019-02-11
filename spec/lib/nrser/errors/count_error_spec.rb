class String
  def to_re
    # Regexp.new Regexp.escape( self )
    /#{ Regexp.escape( self ) }/
  end
end

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
  

  CASE ~%{ in action } do
  # ==========================================================================
    
    METHOD [].method( :to_proc ) do
      CALLED do
        it do
          expect { subject }.to raise_error NRSER::CountError,
            /Can not create getter proc from empty array/; end; end; end
    

    METHOD [].method( :only! ) do
      CALLED do
        it do
          expect { subject }.to raise_error NRSER::CountError, (~%{
            Array object [] has invalid #count attribute, expected 1, found 0
          }).to_re; end; end; end
    
  end # CASE in action ************************************************
  

end # SPEC_FILE