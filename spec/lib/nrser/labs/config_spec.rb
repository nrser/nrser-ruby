require 'nrser/labs/config'

describe_spec_file(
  spec_path: __FILE__,
  class: NRSER::Config,
  labs: true, # run with `LABS=1 rspec ...` to include
) do

  
  describe_section "basic shit" do
  # ========================================================================
    
    subject { described_class.new( {x: 1, y: 2}, {y: 3, z: 4} ) }

    it do
      is_expected.to include x: 1, y: 3, z: 4
    end
    
  end # section basic shit
  # ************************************************************************

end