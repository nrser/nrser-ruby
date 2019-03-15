# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###

require_relative '../text'


# Refinements
# =======================================================================


# Namespace
# =======================================================================

module  NRSER
module  Text


# Definitions
# =======================================================================

# @example
#   ::NRSER::Text::List.new( 'a', 'b', 'c' ).render_text
#   #=> "a, b, c"
# 
# @example
#   ::NRSER::Text::List.new( 'a', 'b', and: 'c' ).render_text
#   #=> "a, b and c"
#
# @example Use Oxford-style with a coordinating conjunction
#   ::NRSER::Text::List.new( 'a', 'b', and: 'c', oxford: true ).render_text
#   #=> "a, b, and c"
# 
class List < ::Array
  
  # Mixins
  # ==========================================================================
  
  # Just used as a flag of sorts to indicate that this is a text object that
  # can be {#render}ed.
  include Text
  
  
  # Constants
  # ==========================================================================
  
  LAST_JOIN_KEYS = Set[ :and, :or, :'and/or' ].freeze
  
  
  # Attributes
  # ==========================================================================
  
  # {::String} to join entries with in {#to_s} (except the last two when 
  # the instance has a {#last_join}).
  # 
  # @return [::String]
  #     
  attr_reader :join_with
  
  
  # Coordinating conjunction - Optional special {::String} to join the
  # next-to-last and last entries in string representations (available via
  # {#to_s}).
  #
  # @return [nil]
  #   Doesn't do anything special for the last join.
  # 
  # @return [::String]
  #   {::String} with which to join the last two entries.
  #   
  attr_reader :last_join
  
  
  # Construction
  # ==========================================================================
  
  def initialize *entries, join_with: ', ', oxford: false, **options
    @join_with = join_with.to_s
    
    # Use Oxford comma?
    @oxford = !!oxford
    
    # Figure out the last join string option, if any
    
    last_join_options = {}
    
    options.reject! { |key, value|
      if LAST_JOIN_KEYS.include? key
        last_join_options[ key ] = value
        true
      end
    }
    
    case last_join_options.length
    when 0
      # No last join options present, nothing to do
    when 1
      # We got (exactly) one
      last_join, entry = last_join_options.first
      
      # Set the instance variable
      @last_join = last_join.to_s
      
      # And add the entry to the end of the rest
      entries << entry
    else
      raise ArgumentError.new \
        "Expected exclusively one of", LAST_JOIN_KEYS, "in `options`,",
        "given", last_join_options.length,
        last_join_options: last_join_options
    end
    
    super( entries )
  end
  
  
  # Instance Methods
  # ==========================================================================
  
  # Use Oxford-style commas/etc..?
  # 
  # @return [Boolean]
  # 
  def oxford?
    @oxford
  end
  
  
  # Render the {List} into a final {::String}.
  # 
  # @param [Renderer] renderer
  #   {Renderer} to use.
  # 
  # @return [String]
  # 
  def render renderer = Text.default_renderer
    if last_join
      if oxford?
        renderer.join *self[ 0..-2 ], last_join, self[ -1 ], with: join_with
      else
        renderer.join \
          renderer.join( *self[ 0..-2 ], with: join_with ),
          last_join,
          self[ -1 ]
      end
    else
      renderer.join *fragments, with: join_with
    end
  end # #render
  
  
  # Language Integration Instance Methods
  # --------------------------------------------------------------------------
  
  def to_s
    render
  end
  
end # List


# /Namespace
# =======================================================================

end # module  Text
end # module  NRSER
