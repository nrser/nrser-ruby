require 'nrser/core_ext/method/full_name'

describe_spec_file(
  spec_path:        __FILE__,
  class:            ::Method,
  instance_method:  :full_name,
) do
  
  describe_setup %{
    get `method_name` from `receiver` and call `#full_name` on it
  }.squish do
    subject do
      receiver.method( method_name ).full_name
    end
    
    describe_case %{ class methods for } do
      
      describe_when receiver: Object, method_name: :new do
        it { is_expected.to eq "Object.new" }
      end
      
      describe_when receiver: NRSER, method_name: :rest do
        it { is_expected.to eq "NRSER.rest" }
      end
      
    end # class methods
    
    
    describe_case "instance methods" do
      describe_when receiver: Object.new, method_name: :to_s do
        it %{ Returns the receiver's class,
              even if method is not defined there }.squish do
          is_expected.to eq "Object#to_s"
        end
      end
      
    end # instance methods
    
  end # setup
  
end # Spec File Description
