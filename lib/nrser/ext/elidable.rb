# encoding: UTF-8
# frozen_string_literal: true

# Requirements
# =======================================================================

### Stdlib ###

### Deps ###

### Project / Package ###


# Namespace
# =======================================================================

module  NRSER
module  Ext


# Definitions
# =======================================================================

# Things that can be elided via an `#ellipsis` method.
# 
module Elidable
  
  # Cut the middle out of a sliceable object with length and stick an ellipsis
  # in there instead.
  # 
  # Categorized with {String} functions 'cause that's where it started, and
  # that's probably how it will primarily continue to be used, but tested to
  # work on {Array} and should for other classes that satisfy the same
  # slice and interface.
  # 
  # @param [V & #length & #slice & #<< & #+] source
  #   Source object. In practice, {String} and {Array} work. In theory,
  #   anything that responds to `#length`, `#slice`, `#<<` and `#+` with the
  #   same semantics will work.
  # 
  # @param [Fixnum] max
  #   Max length to allow for the output string.
  # 
  # @param [String] omission
  #   The string to stick in the middle where original contents were
  #   removed. Defaults to the unicode ellipsis since I'm targeting the CLI
  #   at the moment and it saves precious characters.
  # 
  # @return [V]
  #   Object of the same type as `source` of at most `max` length with the
  #   middle chopped out if needed to do so.\*
  #   
  #   \* Really, it has to do with how all the used methods are implemented,
  #   but we hope that conforming classes will return instances of their own
  #   class like {String} and {Array} do.
  # 
  def ellipsis max, omission: Char::ELLIPSIS.char
    return self unless length > max
    
    trim_length = max - ( is_a?( ::String ) ? omission.length : 1 )
    
    if trim_length <= 0
      raise ArgumentError.new \
        "Too short - `max` and `omission` length result in no content",
        max: max,
        omission: omission,
        omission_length: omission.length,
        self: self
    end
    
    half = trim_length / 2
    remainder = trim_length % 2
    
    start = slice 0, half + remainder
    start << omission
    
    finish = slice (length - half), half
    
    start + finish
  end # .ellipsis
  
  
  # TODO  Make this configurable...
  [ ::String, ::Array ].each do |class_|
    refine class_ do
      prepend Elidable
    end
  end
  
end # module Elidable

# /Namespace
# =======================================================================

end # module  Ext
end # module  NRSER

