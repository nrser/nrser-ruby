# frozen_string_literal: true
# encoding: UTF-8


# Requirements
# ========================================================================

# Project / Package
# ------------------------------------------------------------------------

require_relative './is'
require_relative './is_a'
require_relative './attributes'
require_relative './not'

  
# Namespace
# ========================================================================

module  NRSER
module  Types


# Definitions
# ========================================================================
  
# @!group String Type Factories
# ----------------------------------------------------------------------------

#@!method self.String length: nil, encoding: nil, **options
#   Get a {Type} whose members {.IsA} {String}, along with some other optional
#   common attribute checks ({String#length} and {String#encoding}).
#   
#   If `encoding:` is specified and no `from_s:` is provided, will add a
#   {Type#form_s} that attempts to transcode strings that are not already in the
#   target encoding (via a simple `String#encode( encoding )`).
#   
#   If you for some reason don't want {Type#from_s} to try to transcode, just 
#   provide a `from_s:` {Proc} that doesn't do it - `->( s ) { s }` to just
#   use whatever tha cat drags in.
#   
#   If `from_s` is otherwise not provided, adds the obvious identity function.
#   
#   @param [nil | Integer | {min: Integer?, max: Integer?, length: Integer?}]
#     length
#     Optionally admit only strings of a specified length. This does not affect
#     any default `from_s` - loaded strings must already be the specific length.
#   
#   @param [String] encoding
#     Optional {String#encoding} check. See notes above regarding default
#     `from_s` that may be added.
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :String,
  aliases:      [ :str ],
&->( length: nil, encoding: nil, **options ) do

  if [ length, encoding ].all?( &:nil? )
    # Give 'er the obvious `#from_s` if she don't already have one
    options[:from_s] ||= ->( s ) { s }

    IsA.new ::String, **options
    
  else
    types = [ IsA.new( ::String ) ]
    types << self.Length( length ) if length

    if encoding
      # If we didn't get a `from_s`, provide one that will try to transcode to
      # `encoding` (unless it's already there)
      options[:from_s] ||= ->( string ) {
        if string.encoding == encoding
          string
        else
          string.encode encoding
        end
      }

      types << self.Attributes( encoding: encoding )

    else
      # We don't need to handle encoding, so set the obvious `#from_s` if 
      # one was not provided
      options[:from_s] ||= ->( s ) { s }

    end
    
    self.Intersection *types, **options
  end

end # .String


#@!method self.EmptyString encoding: nil, **options
#   Get a {Type} only satisfied by empty strings.
#   
#   @param encoding (see .String)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :EmptyString,
  aliases:      [ :empty_str ],
&->( encoding: nil, **options ) do
  self.String **options, length: 0, encoding: encoding
end # .EmptyString


#@!method self.NonEmptyString encoding: nil, **options
#   {.String} of length `1` or more.
#   
#   @param encoding (see .String)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :NonEmptyString,
  aliases:      [ :non_empty_str ],
&->( encoding: nil, **options ) do
  self.String  **options, length: {min: 1}, encoding: encoding
end # .NonEmptyString


#@!method self.Character encoding: nil, **options
#   {.String} of length `1` (Ruby lacks a character class).
#   
#   @param encoding (see .String)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :Character,
  aliases:      [ :char ],
&->( encoding: nil, **options ) do
  self.String **options, length: 1, encoding: encoding
end # .Character


#@!method self.UTF8String length: nil, **options
#   A type satisfied by UTF-8 encoded {.String}.
#   
#   @param length (see .String)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :UTF8String,
  # NOTE        "UTF8String".underscore -> "utf8_string"
  aliases:      [ :utf_8_string,
                  :utf8,
                  :utf_8,
                  :utf8_str,
                  :utf_8_str ],
&->( length: nil, **options ) do
  self.String **options, length: length, encoding: Encoding::UTF_8
end # .UTF8String


#@!method self.UTF8Character **options
#   A type satisfied by UTF-8 encoded {.Character}.
#   
#   @param encoding (see .String)
#   
#   @param [Hash] options
#     Passed to {Type#initialize}.
#   
#   @return [Type]
#   
def_type        :UTF8Character,
  # NOTE        "UTF8Character".underscore -> "utf8_character"
  aliases:      [ :utf_8_character,
                  :utf8_char,
                  :utf_8_char ],
&->( **options ) do
  self.Character **options, encoding: Encoding::UTF_8
end # .UTF8Character


# @!endgroup String Type Factories # *****************************************


# /Namespace
# ========================================================================

end # module Types
end # module NRSER
