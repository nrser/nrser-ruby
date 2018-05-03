require 'nrser/core_ext/hash'

describe_spec_file(
  spec_path: __FILE__,
) do
  
  describe_setup "'short' transform keys methods under inheritance" do
    
    def self.str_hash; {'x' => 1, 'y' => 2}; end
    def str_hash; self.class.str_hash; end
    
    def self.sym_hash; {x: 1, y: 2}; end
    def sym_hash; self.class.sym_hash; end
    
    [Hash, HashWithIndifferentAccess].each do |hash_class|
      describe_class hash_class do
        [str_hash, sym_hash].each do |source_hash|
          describe "#{ described_class.name }[#{ str_hash }]" do
            subject do
              described_class.send :[], source_hash
            end
            
            describe_instance_method :sym_keys do
              describe_called_with() do
                it { is_expected.to eq subject.symbolize_keys }
              end
            end
            
            describe_instance_method :str_keys do
              describe_called_with() do
                it { is_expected.to eq subject.stringify_keys }
              end
            end
          end # instance str_hash
        end
      end
    end
  end
  
end # spec file
