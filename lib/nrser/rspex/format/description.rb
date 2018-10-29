# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './list'
require_relative './kwds'


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  Format


# Definitions
# =======================================================================

# A {List} that in specific represents arguments to a method.
# 
class Description < ::String
  def self.string_for element
    if element.respond_to? :to_desc
      desc = element.to_desc
      if desc.empty?
        ''
      else
        Format.md_code_quote desc
      end
    else
      case element
      when ::Module
        mod = element
        
        name_desc = if mod.anonymous?
          "(anonymous #{ element.class })"
        else
          Format.md_code_quote mod.name
        end
        
        "#{ name_desc } (#{ string_for mod.n_x.source_location })"
        
      when NRSER::Meta::Source::Location
        if element.valid?
          "#{ NRSER::RSpex.dot_rel_path( element.file ) }:#{ element.line }"
        else
          ''
        end
        
      when String
        element
      
      when Pathname
        Format.pathname element
      
      when NRSER::Message
        [element.symbol, element.args].
          map( &NRSER::RSpex.method( :short_s ) ).
          join( ', ' )
        
      else
        NRSER::RSpex.short_s element
        
      end
    end
  end

  
  # TODO document `raw_elements` attribute.
  # 
  # @return [Array<Object>]
  # 
  attr_reader :raw_elements


  # TODO document `strings` attribute.
  # 
  # @return [Array<String>]
  # 
  attr_reader :strings


  
  # TODO document `joined` attribute.
  # 
  # @return [attr_type]
  #   
  attr_reader :joined

  
  # The RSpex "description type" associated with this description. May be `nil`
  # if there is no associated description type.
  # 
  # @return [Symbol?]
  #   
  attr_reader :type


  def initialize *raw_elements, type: nil
    @raw_elements = raw_elements
    @strings = raw_elements.map { |e| self.class.string_for e }
    @joined = @strings.join( ' ' ).squish
    @type = type
    super( Format.prepend_type type, Format.mean_streak.render( @joined ) )
  end


  def to_desc max = nil
    if max
      truncate max
    else
      self
    end
  end
end


# /Namespace
# =======================================================================

end # module  Format
end # module  RSpex
end # module  NRSER
