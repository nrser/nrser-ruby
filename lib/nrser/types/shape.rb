# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './type'


# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# =======================================================================


class Shape < Type  
  
  # Attributes
  # ========================================================================
  
  # TODO document `pairs` attribute.
  # 
  # @return [Hash]
  #     
  attr_reader :pairs
  
  
  # Constructor
  # ======================================================================
  
  # Instantiate a new `NRSER::Types::Shape`.
  def initialize pairs, **options
    super **options
    @pairs = pairs.map { |k, v|
      [k, NRSER::Types.make( v )]
    }.to_h.freeze
  end # #initialize
  
  
  # Instance Methods
  # ======================================================================
  
  def test? value
    begin
      @pairs.all? { |k, v| v === value[k] }
    rescue
      false
    end
  end


  # @!group Display Instance Methods
  # --------------------------------------------------------------------------
  
  def string_format pre:, post:, method:, spaces: true
    space = spaces ? ' ' : ''

    inner = @pairs.map { |k, v|
      key_part = if k.is_a? Symbol
        "#{ k }:#{ space }"
      else
        "#{ k.inspect }#{ space }=>#{ space }"
      end

      key_part + v.public_send( method )
    }

    pre + inner.join( ",#{ space }" ) + post
  end


  def default_symbolic
    string_format pre: '{', post: '}', method: :symbolic
  end


  def explain
    string_format pre: 'Shape<', post: '>', method: :explain
  end

  # @!endgroup Display Instance Methods # ************************************
  

  def has_from_data?
    pairs.values.all? { |type| type.has_from_data? }
  end
  
  
  def custom_from_data data
    pairs.map { |key, type|
      [ key, type.from_data( data[key] ) ]
    }.to_h
  end
  
end # class Shape


def_type          :Shape,
  parameterize:   true,
&->( pairs, **options ) do
  Shape.new pairs, **options
end
  

# /Namespace
# ========================================================================

end # module Types
end # module NRSER

