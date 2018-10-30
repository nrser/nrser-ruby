require 'nrser/meta/lazy_attr'

SPEC_FILE(
  spec_path:        __FILE__,
  class:            NRSER::LazyAttr,
) do
  
  SETUP %{ Decorate a class instance method } do
    my_class = Class.new do
      extend ::MethodDecorators
      
      def self.name
        'MyClass'
      end
      
      attr_reader :count
      
      def initialize
        @count = 0
      end
      
      +NRSER::LazyAttr
      def f
        @count += 1
        'eff!'
      end
      
    end
    
    instance = my_class.new
    
    it %{ starts out with call count 0 } do
      expect( instance.count ).to be 0
    end
    
    it %{ returns the correct result when called } do
      expect( instance.f ).to eq 'eff!'
    end
    
    it %{ now has the instance variable set } do
      expect( instance.instance_variable_get :@f ).to eq 'eff!'
    end
    
    it %{ now has call count 1 } do
      expect( instance.count ).to be 1
    end
    
    it %{ returns the same result when called again } do
      expect( instance.f ).to eq "eff!"
    end
    
    it %{ still has call count 1 } do
      expect( instance.count ).to be 1
    end
    
    it %{ still has the instance var set to the result } do
      expect( instance.instance_variable_get :@f ).to eq 'eff!'
    end
    
  end # instance method
  
  
  SETUP %{ Decorate a class method } do
    my_class = Class.new do
      extend ::MethodDecorators
      
      def self.name
        'MyClass'
      end
      
      @count = 0
      
      def self.count
        @count
      end
      
      +NRSER::LazyAttr
      def self.f
        @count += 1
        'eff!'
      end
      
    end
    
    it %{ starts out with call count 0 } do
      expect( my_class.count ).to be 0
    end
    
    it %{ returns the correct result when called } do
      expect( my_class.f ).to eq 'eff!'
    end
    
    it %{ now has the instance variable set } do
      expect( my_class.instance_variable_get :@f ).to eq 'eff!'
    end
    
    it %{ now has call count 1 } do
      expect( my_class.count ).to be 1
    end
    
    it %{ returns the same result when called again } do
      expect( my_class.f ).to eq "eff!"
    end
    
    it %{ still has call count 1 } do
      expect( my_class.count ).to be 1
    end
    
    it %{ still has the instance var set to the result } do
      expect( my_class.instance_variable_get :@f ).to eq 'eff!'
    end
    
  end # class method
  
end # Spec File Description
