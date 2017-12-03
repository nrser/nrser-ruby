require 'nrser/meta/props'

require 'nrser/refinements'
using NRSER

require 'nrser/refinements/types'
using NRSER::Types


describe NRSER::Meta::Props do
  
  describe_section "to and from data" do
  # ========================================================================
    
    before( :all ) {
      @cat_class = Class.new( NRSER::Meta::Props::Base ) do
        prop :name, type: t.non_empty_str
        prop :breed, type: t.non_empty_str
        prop :age, type: t.unsigned
        
        def self.name; 'Cat'; end
      end
    }
    
    describe_group "simple nesting" do
      
      before( :all ) {
        # IMPORTANT!!!  must bind *outside* the class declaration; can't use
        #               @cat_class in there because it resolves to a (nil)
        #               instance variable of the new class.
        cat_class = @cat_class
        
        @owner_class = Class.new( NRSER::Meta::Props::Base ) do
          prop :name, type: t.non_empty_str
          
          prop :cat, type: cat_class
          
          def self.name; 'Owner'; end
        end
        
        @cat = @cat_class.new name: "Hooty", breed: "American Shorthair", age: 2
        
        @owner = @owner_class.new name: "Neil", cat: @cat
      }
      
      it "is setup correctly" do
        expect( @cat_class ).to be_a Class
        expect( @cat_class.is_a? ::Class ).to be true
        expect( @cat_class.name ).to eq "Cat"
        expect( t.make @cat_class ).to be_a NRSER::Types::IsA
        
        name_prop = @owner_class.props[:name]
        expect( name_prop.type ).to be t.non_empty_str
        
        cat_prop = @owner_class.props[:cat]
        expect( cat_prop.type ).to be_a NRSER::Types::IsA
        expect( cat_prop.type.klass ).to be @cat_class
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
