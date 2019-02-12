# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# ========================================================================

### Project / Package ###

#### Sub-Tree ####
require_relative './list'
require_relative './kwds'


# Refinements
# ============================================================================

require 'nrser/ext/module'
using NRSER::Ext::Module

require 'nrser/ext/pathname'
using NRSER::Ext::Pathname


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  Format


# Definitions
# =======================================================================

# The core string-description-making functionality.
# 
class Description < ::String
  
  def self.string_for raw_element
    if raw_element.respond_to? :to_desc
      desc = raw_element.to_desc
      if desc.empty?
        ''
      else
        Format.md_code_quote desc
      end
    else
      case raw_element
      when ::Module
        mod = raw_element
        
        name_desc = if mod.anonymous?
          "(anonymous #{ raw_element.class })"
        else
          Format.md_code_quote mod.name
        end
        
        source_location_string = string_for mod.source_location

        if source_location_string.empty?
          name_desc
        else
          "#{ name_desc } (#{ source_location_string })"
        end
        
      when Meta::Source::Location
        if  raw_element.valid? && 
            Pathname.getwd.subpath?( raw_element.file ) &&
            !Pathname.getwd.join( '.bundle' ).subpath?( raw_element.file )
          [
            Pathname.new( raw_element.file ).to_dot_rel_s,
            raw_element.line
          ].join ';'
        else
          ''
        end
        
      when ::String
        raw_element
      
      when ::Pathname
        Format.pathname raw_element
      
      when Message
        [raw_element.symbol, raw_element.args].
          map( &Format.method( :short_s ) ).
          join( ', ' )
      
      when Proc
        # src_loc = value.source_location
        "Proc"

      else
        Format.short_s raw_element
        
      end
    end
  end # .string_for
  
  
  def self.prepend_type type, description
    return description if type.nil?
    
    prefix = Format.pastel.magenta \
      Format.i( type.to_s.upcase.gsub('_', ' ') )
    
    "#{ prefix } #{ description }"
  end # .prepend_type

  
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

  
  # The RSpec "description type" associated with this description. May be `nil`
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
    super( self.class.prepend_type type, Format.mean_streak.render( @joined ) )
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
end # module  RSpec
end # module  Described
end # module  NRSER
