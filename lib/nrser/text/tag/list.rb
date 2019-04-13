# encoding: UTF-8
# frozen_string_literal: true
# doctest: true

# Requirements
# =======================================================================

### Project / Package ###

require 'nrser/text'
require_relative '../tag'


# Namespace
# =======================================================================

module  NRSER
module  Text
module  Tag


# Definitions
# =======================================================================

# @example
#   List.new( 'a', 'b', 'c' ).render
#   #=> "a, b, c"
# 
# @example
#   List.new( 'a', 'b', and: 'c' ).render
#   #=> "a, b and c"
#
# @example Use Oxford-style with a coordinating conjunction
#   List.new( 'a', 'b', and: 'c', oxford: true ).render
#   #=> "a, b, and c"
# 
class List < ::Array
  
  # @todo document Item class.
  # 
  class Item
    
    # Mixins
    # ========================================================================
    
    include Tag
    
    
    # Attributes
    # ==========================================================================
    
    # TODO document `blocks` attribute.
    # 
    # @return [attr_type]
    #     
    attr_reader :blocks
    
    
    # Construction
    # ========================================================================
    
    # Instantiate a new `Item`.
    def initialize *blocks
      @blocks = blocks.freeze
    end # #initialize
    
  end # class Item
  
  # Mixins
  # ==========================================================================
  
  include Tag
  
  
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
  
  def initialize *entries,  join_with: ', ',
                            oxford: false,
                            ordered: false,
                            **options
    @join_with = join_with.to_s
    
    # Is this an ordered list?
    @ordered = !!ordered
    
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
  
  
  # Is this an ordered list (usually displayed with numbered items)?
  # 
  # @return [Boolean]
  # 
  def ordered?
    @ordered
  end # #ordered?
  
  
  # Render the {List} into a final {::String}.
  # 
  # @param [Renderer] renderer
  #   {Renderer} to use.
  # 
  # @return [String]
  # 
  def render renderer = Text.default_renderer, options = nil
    options = renderer.options.merge options
    join_with_options = options.update :join_with, join_with
    
    if last_join
      if oxford?
        except_last = \
          renderer.join *self[ 0..-2 ], last_join, options: join_with_options
        
        renderer.join except_last, self[ -1 ], options: options
      else
        renderer.join \
          renderer.join( *self[ 0..-2 ], options: join_with_options ),
          last_join,
          self[ -1 ],
          options: options
      end
    else
      renderer.join *self, options: join_with_options
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

end # module  Tag
end # module  Text
end # module  NRSER
