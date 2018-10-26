# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

# Need {NRSER::Ext::Enumerable::Associate#assoc_by}
require_relative './associate'


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# ========================================================================

module Enumerable
  
  # @note EXPERIMENTAL!
  # 
  # An idea I'm playing around with for convenient mapping of {Enumerable}.
  # 
  # @example Extract Attributes
  #   Cat   = Struct.new :name, :breed
  #   
  #   cats  = [ Cat.new( 'Hudie', 'Chinese-American Shorthair' ),
  #             Cat.new( 'Oscar', 'Bengal' ) ]
  #   
  #   cats/:name  #=> [ 'Hudie', 'Oscar' ]
  #   cats/:breed #=> [ 'Chinese-American Shorthair', 'Bengal' ]
  # 
  # @example Extract Values
  #   # Need the array.to_proc ~> ->( key ) { array.dig *key } for it to really
  #   # *feel* nice... and that's the whole point!
  #   require 'nrser/core_ext/array/to_proc'
  #   
  #   kitties = [ { name: 'Hootie' }, 
  #               { name: 'Oscie'  } ]
  #   
  #   kitties/[:name] #=> [ 'Hooie', 'Oscie' ]
  # 
  # Not so bad, eh? I'm calling it "slash-map" for the moment, BTW.
  # 
  # @param [#to_proc] proc_able
  #   Something that can be `#to_proc`'d for the {Enumerable#map}.
  # 
  # @return [Enumerable]
  # 
  def / proc_able
    map &proc_able
  end
  
end # module Enumerable


# /Namespace
# ========================================================================

end # module Ext
end # module NRSER
