require 'nrser/meta/names'
require 'nrser/rspex/described'

Names = NRSER::Meta::Names

def re; NRSER::Regexp::Composed; end


def curly_quote *patterns
  re.join re.esc( '{' ), *patterns, re.esc( '}' )
end


def backtick_quote *patterns
  re.join re.esc( '`' ), *patterns, re.esc( '`' )
end


ParameterType \
  name: 'class',
  regexp: curly_quote( Names::Module ),
  type: Names::Module,
  transformer: ->( string ) { Names::Module.new string[ 1..-2 ] }


ParameterType \
  name: 'attr',
  regexp: backtick_quote( Names::Attribute ),
  type: Names::Attribute,
  transformer: ->( string ){ Names::Attribute.new string[ 1..-2 ] }


ParameterType \
  name: 'method',
  regexp: re.or(
    backtick_quote( Names::Method ),
    curly_quote( Names::SingletonMethod ),
  ),
  type: Names::Name,
  transformer: ->( string ){
    Names.match string[ 1..-2 ],
      Names::Method,          ->( _ ) { _ },
      Names::SingletonMethod, ->( _ ) { _ }
  }


ParameterType \
  name: 'qualified_method',
  regexp: re.or(
    curly_quote( Names::QualifiedSingletonMethod ),
    curly_quote( Names::QualifiedInstanceMethod ),
  ),
  type: Names::Name,
  transformer: ->( string ){
    Names.match string[ 1..-2 ],
      Names::QualifiedSingletonMethod,  ->( _ ) { _ },
      Names::QualifiedInstanceMethod,   ->( _ ) { _ }
  }


ParameterType \
  name: 'described',
  regexp: NRSER::RSpex::Described.human_name_pattern,
  type: ::String,
  transformer: ->( string ){ string }


ParameterType \
  name: 'expr',
  regexp: re.join( re.esc( '`' ), '.*', re.esc( '`' ) ),
  type: ::String,
  transformer: ->( string ){ string[ 1..-2 ] }

  
# class ParamName
  
#   def self.from_s string
#     if string.start_with?( '&' ) && string.end_with?( ':' )
#       raise NRSER::ArgumentError.new \
#         "`string` can not start with '&' and end with ':', found",
#         string.inspect
#     end
    
#     name, type = if string.start_with? '&'
#       [ string[ 1..-1 ], :block ]
#     elsif string.end_with? ':'
#       [ string[ 0..-2 ], :keyword ]
#     else
#       [ string, :positional ]
#     end
    
#     new name: name, type: type
#   end
  
  
#   # The parameter name (without `&` prefix or `:` suffix).
#   # 
#   # @return [String]
#   #     
#   attr_reader :name
  
  
#   # The parameter type.
#   # 
#   # @return [:positional | :keyword | :block]
#   #     
#   attr_reader :type
  
  
#   def initialize name:, type:
#     @name = name
#     @type = type
#   end
  
# end
  

# ParameterType \
#   name: 'param',
#   regexp: /\&?[a-zA-Z0-9_]+\:?/,
#   type: ParamName,
#   transformer: ParamName.method( :from_s ),
#   use_for_snippets: false


# ParameterType \
#   name: 'const',
#   regexp: /(?:\:\:)?[A-Z_][a-zA-Z0-9_]*(?:\:\:[A-Z_][A-Za-z0-9_]*)*/,
#   type: ::String,
#   transformer: ->( string ) { string }


# ParameterType \
#   name: 'any',
#   regexp: /.*/,
#   type: ::String,
#   transformer: ->( string ) { string },
#   use_for_snippets: false
  