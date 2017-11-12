

# @todo document NRSER::TestFixtures:: module.
module NRSER::TestFixtures::AbstractMethodError
  
  class Base
    def f
      raise NRSER::AbstractMethodError.new( self, __method__ )
    end
  end
  
  class Sub < Base; end
  
end # module NRSER::TestFixtures::AbstractMethodError


describe_class NRSER::AbstractMethodError do
  
  context(
    "when raising method is invoked through instance of defining class"
  ) do
    
    it "explains that the instance's class is abstract" do
      expect {
        NRSER::TestFixtures::AbstractMethodError::Base.new.f
      }.to raise_error(
        NRSER::AbstractMethodError,
        /Base is an abstract class/
      )
    end
    
  end # when raising method is invoked through instance of defining class
  
  context "when raising method is invoked through instance of a subclass" do
    
    it "explains that an implementing class needs to be found or written" do
      expect {
        NRSER::TestFixtures::AbstractMethodError::Sub.new.f
      }.to raise_error(
        NRSER::AbstractMethodError,
        /find a subclass of .*Sub to instantiate or write your own/
      )
    end
    
  end # when raising method is invoked through instance of a subclass
  
  
end # Class NRSER::AbstractMethodError Description

