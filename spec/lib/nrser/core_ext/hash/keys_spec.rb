require 'active_support/hash_with_indifferent_access'

require 'nrser/core_ext/hash/keys'

SPEC_FILE(
  spec_path: __FILE__,
  # TODO  Incorporate this into the `METHOD` example groups to override the
  #       not-useful source location they get due to dynamic method generator?
  # source_file: 'nrser/core_ext/hash/keys.rb',
) do
  
  EACH *[
    [ ::Hash, ::HashWithIndifferentAccess ],
    [ { 'x' => 1, 'y' => 2 }, { x: 1, y: 2} ],
   ] do |klass, source_hash|

    OBJECT klass[ source_hash ] do

      it do is_expected.to be_a klass end
      
      METHOD :sym_keys do
        CALLED do it ~%{ is equal to calling .symbolize_keys } do
          is_expected.to eq subject.symbolize_keys end
        end
      end
      
      METHOD :str_keys do
        CALLED do it ~%{ is equal to calling .stringify_keys } do
          is_expected.to eq subject.stringify_keys end
        end
      end

    end # OBJECT
  end # EACH
end # SPEC_FILE
