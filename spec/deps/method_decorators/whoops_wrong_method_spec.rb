require 'method_decorators'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           MethodDecorators,
) do
  
  M = Module.new # do
  
  class M::EnumFor < MethodDecorators::Decorator
    # @param [Method] target
    #   The decorated method, already bound to the receiver.
    #   
    #   The `method_decorators` gem calls this `orig`, but I thought `target`
    #   made more sense.
    # 
    # @param [*] receiver
    #   The object that will receive the call to `target`.
    #   
    #   The `method_decorators` gem calls this `this`, but I thought `receiver`
    #   made more sense.
    #   
    #   It's just `target.receiver`, but the API is how it is.
    # 
    # @param [Array] *args
    #   Any arguments the decorated method was called with.
    # 
    # @param [Proc?] &block
    #   The block the decorated method was called with (if any).
    # 
    def call target, receiver, *args, &block
      if block
        target.call *args, &block
      else
        receiver.enum_for target.name, *args
      end
    end
  end # EnumFor
  
  class M::A
    extend ::MethodDecorators
    
    +M::EnumFor
    def self.f &block
      block.call __method__
    end
  end
  
  class M::B
    +M::EnumFor
    def self.g &block
      block.call __method__
    end
  end
  
  CLASS M::A do
    it do is_expected.to be_a MethodDecorators end
    
    METHOD :f do
      WHEN "called with a `&block` param" do
        subject do super().call { |x| "yielded from #{ x }" } end
        
        it ~%{ works fine } do is_expected.to eq "yielded from f" end
      end
      
      WHEN "called with no params" do
        CALLED do
          it ~%{ works as well, returning an {Enumerator} } do
            is_expected.to be_a Enumerator end
          
          METHOD :map do
            WHEN ~%{ called with a block } do
              subject do super().call { |x| "yielded from #{ x }" } end
              
              it ~%{ works fine } do is_expected.to eq [ "yielded from f" ] end
            end
          end
        end
      end
      
      # enum = M::A.f
      
      # expect( enum ).to be_a ::Enumerator
      # expect( enum.map { |x| "yielded #{ x }" } ).to eq [ "yielded f" ]
    end
  end
  
  it ~%{ works when it works } do
    expect( M::B.g { |x| "yielded #{ x }"} ).to eq "yielded g"
    
    expect { M::B.g }.to raise_error NoMethodError
    
  end
  
end # SPEC_FILE