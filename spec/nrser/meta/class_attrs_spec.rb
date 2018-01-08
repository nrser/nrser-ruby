describe NRSER::Meta::ClassAttrs do
  # I'm writing this as I'm developing the module, so I'm going to walk through
  # some of the motivation, features and differences from other approaches
  # as notes to self/others...
  # 
  
  
  # Setup
  # =====================================================================
  # 
  # Because any changes would global and RSpec seems to do things some-what
  # asynchronously we need to use dynamic class creation, which is sub-optimal
  # because it has subtle difference with normal definitions (@@ variable
  # declaration being the major one I've hit do far), but it seems like the
  # most reasonable way to go about it at the moment.
  # 
  
  let (:base) {
    Class.new do
      include NRSER::Meta::ClassAttrs
      
      # To compare, I'll also work with standard '@@' class variables and
      # an standard attr_accessors added to the classes themselves.
      
      # Normally this would be
      # 
      # @@base_class_var = :base_class_var_value
      # 
      # but that is different for dynamic classes, to we use
      class_variable_set :@@base_class_var, :base_class_var_value
      
      class << self
        attr_accessor :base_self_attr_accessor
      end
      
      # Set the self attr_accessor value
      self.base_self_attr_accessor = :base_self_attr_accessor_value
      
      # And now some variables using the mixin.
      
      # I won't ever set this
      class_attr_accessor :never_set
      
      # I'll define this here, but won't set it from base
      class_attr_accessor :def_in_base
      
      # These will be set from here
      class_attr_accessor :set_in_base_1
      class_attr_accessor :set_in_base_2
      
      # There are two ways of setting values:
      # 
      # 1.  self assignment:
      
      self.set_in_base_1 = :set_in_base_1_value
      
      #     Not that `x = value` will not work - the `self` is required.
      #     I haven't found any way to get `x = value` to trigger the setter
      #     methods.
      #     
      # 2.  "DSL-style":
      
      set_in_base_2 :set_in_base_2_value
      
      #     This is the style i started with, because it made it really easy
      #     to have nice-feeling DSL-like functionality with minimal work.
      #     
      #     I'm unsure at the moment if it's something I want to keep (probably),
      #     and if so if it should be optional via a flag on
      #     `class_attr_accessor` (seems like a good idea).
      #     
      #     It's "nice", but it's perhaps kind-of counter-intuitive in the Ruby
      #     world?
      # 
      
    end
  }
  
  let(:child_1) {
    Class.new(base) do
    end
  }
  
  let(:child_1_1) {
    Class.new(child_1) do
    end
  }
  
  let(:child_2) {
    Class.new(base) do
    end
  }
  
  let(:child_2_1) {
    Class.new(child_2) do
    end
  }
  
  
  # Tests
  # =====================================================================
  
  describe "Class (@@) Variables and Their Problems" do
  # ---------------------------------------------------------------------
  # 
  # Examples of the desired features that work (OK examples) and those that
  # don't (PROBLEM! examples) for class (@@) variables.
  # 
  
    it "can access @@ variables from base and any subclass (OK)" do
      [base, child_1, child_1_1, child_2, child_2_1].each do |klass|
        expect(
          klass.class_variable_get :@@base_class_var
        ).to be :base_class_var_value
      end
    end
    
    
    context "@@ variable changed in base" do
      let(:new_value) { :new_base_class_var_value }
      
      before {
        base.class_variable_set :@@base_class_var, new_value
      }
      
      it "can access new value from base and any subclass (OK)" do
        [base, child_1, child_1_1, child_2, child_2_1].each do |klass|
          expect(
            klass.class_variable_get :@@base_class_var
          ).to be new_value
        end
      end
    end # @@ variable changed in base
    
    
    context "@@ variable changed in subclass" do
      let(:new_value) { :new_child_1_class_var_value }
      
      before {
        child_1.class_variable_set :@@base_class_var, new_value
      }
      
      # This is the problem: changes to the value anywhere in the hierarchy
      # are global to the hierarchy
      it "reads that value from all classes (PROBLEM!)" do
        [base, child_1, child_1_1, child_2, child_2_1].each do |klass|
          expect(
            klass.class_variable_get :@@base_class_var
          ).to be new_value
        end
      end
    end # @@ variable changed in base
    
  end # Class (@@) Variables and Their Problems
  
  
  describe "Class 'Self' attr_accessor and Their Problems" do
  # ---------------------------------------------------------------------
    
    it "can access from base (OK)" do
      expect(base.base_self_attr_accessor).to be :base_self_attr_accessor_value
    end
    
    it "can't access from any subclasses (PROBLEM!)" do
      [child_1, child_1_1, child_2, child_2_1].each do |klass|
        expect(klass.base_self_attr_accessor).to be nil
      end
    end
    
  end # Class 'Self' Attribute Accessors and Their Problems
  
  
  
  describe "NRSER::ClassAttrs Solution" do
  # ---------------------------------------------------------------------
  # 
  # Examples of the desired features that work (OK examples) and those that
  # don't (PROBLEM! examples) for class 'self' attr_accessor.
  # 
  
    it "raises NoMethodError when accessing unset class attrs" do
      expect { base.never_set }.to raise_error NoMethodError
      expect { base.def_in_base }.to raise_error NoMethodError
    end
    
    
    it "reads values set in base from base and any subclass" do
      [base, child_1, child_1_1, child_2, child_2_1].each do |klass|
        expect(klass.set_in_base_1).to be :set_in_base_1_value
        expect(klass.set_in_base_2).to be :set_in_base_2_value
      end
    end
    
    
    context "class_attr_accessor value changed in base" do
      # With class_attr_accessor, the new value will be visible to base and
      # all subclasses.
      
      let(:new_value) { :new_set_in_base_1_value }
      
      before {
        base.set_in_base_1 = new_value
      }
      
      it "can access new value from base and any subclass" do
        [base, child_1, child_1_1, child_2, child_2_1].each do |klass|
          expect(klass.set_in_base_1).to be new_value
        end
      end
    end # class_attr_accessor value changed in base
    
    
    context "class_attr_accessor value changed in subclass" do
      # With class_attr_accessor, the new value will be visible to the class
      # it is set in and any subclasses without affecting any others.
      
      let(:new_value) { :set_in_child_1 }
      
      before {
        child_1.set_in_base_1 = new_value
      }
      
      it "reads the new value from that class and any subclasses" do
        [child_1, child_1_1].each do |klass|
          expect(klass.set_in_base_1).to be new_value
        end
      end
      
      it "reads the old value from any other classes" do
        [base, child_2, child_2_1].each do |klass|
          expect(klass.set_in_base_1).to be :set_in_base_1_value
        end
      end
      
    end # class_attr_accessor value changed in subclass
    
  end # NRSER::ClassAttrs Solution
  
end # NRSER::ClassAttrs
