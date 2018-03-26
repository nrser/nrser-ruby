require 'nrser/meta/source/location'

describe_spec_file(
  spec_path: __FILE__,
  class: NRSER::Meta::Source::Location,
) do
  
  loc = NRSER.own_class_Methods.first.source_location
  
  context "instantiate from {Method#source_location}" do
    describe_instance loc do
      it do
        is_expected.to be_a( NRSER::Meta::Source::Location ).
          and have_attributes(
            file: loc[0],
            line: loc[1],
            to_s: "#{ loc[0] }:#{ loc[1] }"
          )
      end
      
      describe_method :[] do
        describe_called_with 0 do
          it { is_expected.to eq loc[0] }
        end # called with 0
        
        describe_called_with 1 do
          it { is_expected.to eq loc[1] }
        end # called with 1
      end # Method [] Description
      
      describe_attribute :to_a do
        it { is_expected.to eq loc }
      end # Attribute to_a Description
      
    end # instance loc
  end # instantiate from {Method#source_location}
  
  
  context "instantiate from prop value hash" do
    describe_instance file: loc[0], line: loc[1] do
      it do
        is_expected.to be_a( NRSER::Meta::Source::Location ).
          and have_attributes(
            file: loc[0],
            line: loc[1],
            to_s: "#{ loc[0] }:#{ loc[1] }"
          )
      end
    end
  end # instantiate from prop value hash
  
  
end # spec file
