
Given "decorator is a singleton method" do
  @decorator = :singleton_method
end

When "the decorated method is called" do
  @class = Class.new
  
  case @decorator
  when :singleton_method
    @class.define_singleton_method :singleton_method_decorator \
    do |receiver, target, *args, &block|
       response = target.call *args, &block
       
       
    end
end
