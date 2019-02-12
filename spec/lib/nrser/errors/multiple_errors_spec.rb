# encoding: UTF-8
# frozen_string_literal: true

# Using {NRSER::Ext::Exception#capture}
require 'nrser/ext/exception'

SPEC_FILE(
  spec_path:        __FILE__,
  class:            NRSER::MultipleErrors,
) do
  
  CASE ~%{ formatting } do
  # ==========================================================================
    
    INSTANCE_METHOD :default_message do

      NEW errors: \
        {
          ArgumentError => 1,
          TypeError     => 2,
          RuntimeError  => 1,
        }.flat_map { |error_class, count|
          (1..count).map { |num|
            error_class.new "#{ error_class } ##{ num }"
          }
        } \
      do
        CALLED do it do is_expected.to eq ~%{ 
          4 error(s) occurred - ArgumentError (1), RuntimeError (1),
          TypeError (2)
        } end end
      end # INSTANCE

    end # #default_message


    INSTANCE_METHOD :default_details do

      NEW errors: \
        {
          ArgumentError => 1,
          TypeError     => 2,
          RuntimeError  => 1,
        }.flat_map { |error_class, count|
          (1..count).map { |num|
            error_class.new "#{ error_class } ##{ num }"
          }
        } \
      do
        CALLED do it do is_expected.to eq \
          <<~END
            1.  ArgumentError #1 (ArgumentError):
                  (NO BACKTRACE)
                
            2.  TypeError #1 (TypeError):
                  (NO BACKTRACE)
                
            3.  TypeError #2 (TypeError):
                  (NO BACKTRACE)
                
            4.  RuntimeError #1 (RuntimeError):
                  (NO BACKTRACE)
          END
          end end
      end # INSTANCE

    end # #default_details

    
  end # CASE ~%{ formatting } *********************************************
  
  
end # SPEC_FILE