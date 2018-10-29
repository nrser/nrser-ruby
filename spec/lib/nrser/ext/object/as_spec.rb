require 'nrser/ext/object/as'

SPEC_FILE \
  spec_path:        __FILE__,
  module:           NRSER::Ext::Object \
do
  
  INSTANCE_METHOD :as_hash do
    SETUP ~%{ bind method to `receiver` } do

      subject do
        unbound_method = super()

        ->( *args, &block ) {
          unbound_method.bind( receiver ).call *args, &block
        }
      end # subject

      CASE ~%{ `receiver` is a {Hash} } do
        WHEN receiver: { a: 1 } do
          CALLED do it ~%{ returns itself } do
            is_expected.to be receiver
          end end

          CALLED_WITH :x do it ~%{ does not effect the result } do
            is_expected.to be receiver
          end end
        end#WHEN
      end#CASE

      CASE ~%{ `receiver` is `nil` }, where: { receiver: nil } do
        CALLED do it do is_expected.to eq( {} ) end end

        CALLED_WITH :x do it ~%{ does not effect the result } do
          is_expected.to eq( {} )
        end end
      end#CASE

      CASE ~%{ `receiver` responds to `#to_h` } do
        CASE ~%{ `#to_h` succeeds } do
          WHEN receiver: [ [:a, 1], [:b, 2] ] do
            CALLED do it do is_expected.to eq( a: 1, b: 2 ) end end
          end#WHEN
        end#CASE

        CASE ~%{ `#to_h` fails } do
          WHEN receiver: [ 1, 2, 3 ] do
            CALLED_WITH :a do
              it ~%{ returns a {Hash} with `receiver` keyed as `:a` } do
                is_expected.to eq a: receiver
              end
            end

            CALLED do it do
              expect { subject }.to raise_error ArgumentError
            end end
          end#WHEN
        end#CASE
      end#CASE

    end#SETUP
  end # #as_hash
  

  INSTANCE_METHOD :as_array do
    SETUP ~%{ bind method to `receiver` } do

      subject do
        unbound_method = super()

        ->( *args, &block ) {
          unbound_method.bind( receiver ).call *args, &block
        }
      end # subject

      CASE ~%{ `receiver` is `nil` }, where: { receiver: nil } do
        CALLED do it do is_expected.to eq [] end end
      end#CASE

    end#SETUP
  end#INSTANCE_METHOD
    
end # SPEC_FILE
