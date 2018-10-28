require 'nrser/ext/method/names'

SPEC_FILE(
  spec_path:        __FILE__,
  module:            NRSER::Ext::Method,
  instance_method:  :full_name,
) do
  
  SETUP ~%{
    get `method_name` from `receiver` and call `#full_name` on it
  } do
    subject do
      receiver.method( method_name ).n_x.full_name
    end
    
    CASE ~%{ class methods for } do
      
      WHEN receiver: Object, method_name: :new do
        it { is_expected.to eq "Object.new" }
      end
      
    end # CASE class methods for
    
    
    CASE ~%{ instance methods } do
      WHEN receiver: Object.new, method_name: :to_s do
        it ~%{ Returns the receiver's class,
              even if method is not defined there } do
          is_expected.to eq "Object#to_s"
        end
      end
      
    end # CASE instance methods
    
  end # SETUP
  
end # SPEC_FILE
