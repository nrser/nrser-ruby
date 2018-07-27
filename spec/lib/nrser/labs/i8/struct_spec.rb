require 'nrser/labs/i8/struct'

require 'nrser/refinements/types'
using NRSER::Types

SPEC_FILE(
  spec_path:        __FILE__,
  module:           I8::Struct,
) do
  
  CASE "Extend a {I8::Struct} and add methods" do
    SETUP "Create a rectangle class based on an {I8::Struct}" do

      class NRSER::TestFixtures::I8StructRectangle \
        < I8::Struct.new( width: t.non_neg_int, length: t.non_neg_int )

        def area
          width * length
        end

      end # class NRSER::TestFixtures::I8StructRectangle

      CLASS NRSER::TestFixtures::I8StructRectangle do

        it "is a subclass of {I8::Struct::Hash}" do
          expect( I8::Struct::Hash > subject ).to be true; end
        
        it "includes {I8::Struct}" do
          expect( I8::Struct > subject ).to be true; end

        INSTANCE width: 2, length: 3 do
          it { is_expected.
            to have_attributes width: 2, length: 3, area: 6 }; end
      end

    end # SETUP
  end # CASE

end # SPEC FILE