# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

# Project / Package
# -----------------------------------------------------------------------

require 'nrser/errors/key_error'

require_relative './stash'


# Namespace
# =======================================================================

module  NRSER
module  Hashes


# Definitions
# =======================================================================

# A {::Hash} where keys can not be over-written.
# 
# @see requirements::features::lib::nrser::hashes::write_once Features
# 
class WriteOnce < Stash
  
  # Defines the actual functionality, so it can be mixed-and-matched with other
  # mixins for {Stash}.
  # 
  module Mixin
    
    def convert_key key, **options
      if options[ :for ] == :write && key?( key )
        raise NRSER::KeyError.new \
          "Key", key, "already set",
          key: key,
          current_value: self[ key ]
      end
      
      super( key )
    end
    
    def put key, value
      if key? key
        raise NRSER::KeyError.new \
          "Key", key, "already set",
          key: key,
          current_value: self[ key ],
          provided_value: value
      end
      
      super( key, value )
    end
    
  end # module Mixin
  
  include Mixin
  
end # class WriteOnce


# /Namespace
# =======================================================================

end # module Hashes
end # module NRSER
