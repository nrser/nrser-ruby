# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/decorate'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Decorate,
) do
  
  module NRSER::TestFixtures::Decorate
    
    class A
      extend NRSER::Decorate
      
      def self.singleton_decorator_method receiver, target, *args, &block
        {
          decorator: __method__,
          target: target,
          args: args,
          block: block,
          response: target.call( *args, &block ),
        }
      end
      
      
      def instance_decorator_method receiver, target, *args, &block
        {
          decorator: __method__,
          target: target,
          args: args,
          block: block,
          response: target.call( *args, &block ),
        }
      end
      
      
      decorate :singleton_decorator_method,
      def with_singleton_method_as_part_of_def
        __method__
      end
      
      
      decorate :instance_decorator_method,
      def with_instance_method_as_part_of_def
        __method__
      end
      
      
      # decorate :decorator_method
      # def with_singleton_method_before_def
      #   __method__
      # end
      
      
      def with_singleton_method_after_def
        __method__
      end
      decorate :singleton_decorator_method, :with_singleton_method_after_def
      
    end
    
  end # NRSER::TextFixtures::Decorate
  
  M = NRSER::TestFixtures::Decorate
  
  
  SETUP ~%{ call `method_name` on a new #{ M } with `args` and `&block` } do
    
    subject do M::A.new.send method_name, *args, &block end
    
    let :args   do Args() end
    let :block  do nil end
    
    CASE ~%{ 
      decorates instance methods as part of def
      (`decorate ..., def ...` style)
    } do
      WHEN ~%{ decorator is a {Symbol} (that should be a method name) } do
        WHEN ~%{ the name exists as only a singleton method },
            method_name: :with_singleton_method_as_part_of_def do
          it do is_expected.to include \
            response: method_name,
            args: args,
            block: block end end
        
        WHEN ~%{ the name exists as only an instance method },
          method_name: :with_instance_method_as_part_of_def do
            it do is_expected.to include \
              decorator: :instance_decorator_method,
              response: method_name,
              args: args,
              block: block end end
      end
    end # CASE
    
    CASE ~%{
      decorate instance methods after def },
      where: { method_name: :with_singleton_method_after_def, } \
    do
      it do is_expected.to include \
        response: method_name,
        args: args,
        block: block end
    end # CASE
  
  end # SETUP
  
end # SPEC_FILE