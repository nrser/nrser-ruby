require 'nrser/props'
require 'nrser/props/immutable/hash_variable'

using NRSER::Types


describe NRSER::Props do
  
  describe_section "to and from data" do
  # ========================================================================
    
    non_empty_str = t.non_empty_str
    unsigned = t.unsigned
    
    before( :all ) {
      Cat = @cat_class = Class.new(
        NRSER::Props::Immutable::HashVariable::Base
      ) do
        prop :name, type: non_empty_str
        prop :breed, type: non_empty_str
        prop :age, type: unsigned
        
        def self.name; 'Cat'; end
      end
    }
    
    describe_group "simple nesting" do
      
      before( :all ) {
        # IMPORTANT!!!  must bind *outside* the class declaration; can't use
        #               @cat_class in there because it resolves to a (nil)
        #               instance variable of the new class.
        cat_class = @cat_class
        
        @owner_class = Class.new(
          NRSER::Props::Immutable::HashVariable::Base
        ) do
          
          prop :name, type: non_empty_str
          
          prop :cat, type: cat_class
          
          def self.name; 'Owner'; end
        end
        
        @cat = @cat_class.new \
          name: "Hooty",
          breed: "American Shorthair",
          age: 2
        
        @owner = @owner_class.new name: "Neil", cat: @cat
      }
      
      it "is setup correctly" do
        expect( @cat_class ).to be_a Class
        expect( @cat_class.is_a? ::Class ).to be true
        expect( @cat_class.name ).to eq "Cat"
        expect( t.make @cat_class ).to be_a NRSER::Types::When
        
        name_prop = @owner_class.props[:name]
        expect( name_prop.type ).to be non_empty_str
        
        cat_prop = @owner_class.props[:cat]
        expect( cat_prop.type ).to be_a NRSER::Types::When
        expect( cat_prop.type.object ).to be @cat_class
        expect( @cat_class.respond_to? :from_data ).to be true
        expect( cat_prop.type.has_from_data? ).to be true
      end
      
      it "dumps to and loads from data" do
        data = @owner.to_data
        restored = @owner_class.from_data data
        expect( restored.to_data ).to eq data
      end
      
    end # Group "simple nesting" Description
    
    
  end # section to and from data
  # ************************************************************************
  
end
