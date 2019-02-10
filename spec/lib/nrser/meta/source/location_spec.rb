require 'nrser/meta/source/location'

SPEC_FILE(
  spec_path: __FILE__,
  class: NRSER::Meta::Source::Location,
) do
  
  shared_examples described_class do |valid:, file:, line:|
    it { is_expected.to be_a( described_class ) }
    
    ATTRIBUTE :valid? do
      it { is_expected.to be valid }
    end # Attribute valid? Description
    
    ATTRIBUTE :file do
      it { is_expected.to eq file }
    end # Attribute file Description
    
    ATTRIBUTE :line do
      it { is_expected.to eq line }
    end # Attribute line Description
    
    ATTRIBUTE :to_s do
      it { is_expected.to eq "#{ file || '???' }:#{ line || '???' }" }
    end # Attribute to_s Description
    
    describe_method :[] do
      describe_called_with 0 do
        it { is_expected.to eq file }
      end # called with 0
      
      describe_called_with 1 do
        it { is_expected.to eq line }
      end # called with 1
    end # Method [] Description
    
    ATTRIBUTE :to_a do
      it { is_expected.to eq [file, line] }
    end # Attribute to_a Description
    
    ATTRIBUTE :to_h do
      it { is_expected.to be_a Hash }
      it { is_expected.to eq( {file: file, line: line}.compact ) }
    end # Attribute to_h Description
    
  end # described_class from:
  
  
  context "{Method#source_location} with non-nil file and line" do
    loc = NRSER.own_class_Methods.
      map( &:source_location ).
      find { |src_loc|
        !src_loc.nil? &&
        !src_loc[0].nil? &&
        !src_loc[1].nil?
      }
    
    context "instantiate from source location array" do
      describe_instance loc do
        it_behaves_like described_class,
          valid: true,
          file: loc[0],
          line: loc[1]
      end # instance loc
    end
    
    
    context "instantiate from prop value hash" do
      describe_instance file: loc[0], line: loc[1] do
        it_behaves_like described_class,
          valid: true,
          file: loc[0],
          line: loc[1]
      end
    end
  end # {Method#source_location} with non-nil file and line
  
  
  context "`nil` source location" do
    describe_instance nil do
      it_behaves_like described_class, valid: false, file: nil, line: nil
    end
  end # `nil` source location
  
  
end # SPEC_FILE
