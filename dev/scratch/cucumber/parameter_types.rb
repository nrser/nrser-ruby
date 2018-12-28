# encoding: UTF-8
# frozen_string_literal: true

require 'nrser/meta/names'
require 'nrser/described'


Names = NRSER::Meta::Names

def re; NRSER::Regexps::Composed; end


DOUBLE_QUOTED_STRING_RE = /"(?:[^"\\]|\\.)*"/
SINGLE_QUOTED_STRING_RE = /'(?:[^'\\]|\\.)*'/

QUOTED_STRING_RE = re.or \
  DOUBLE_QUOTED_STRING_RE,
  SINGLE_QUOTED_STRING_RE


def curly_quote *patterns
  re.join re.esc( '{' ), *patterns, re.esc( '}' )
end


def curly_quoted? string
  string[ 0 ] == '{' && string[ -1 ] == '}'
end


def curly_unquote string
  if curly_quoted? string
    string[ 1..-2 ]
  else
    string
  end
end


def backtick_quote *patterns
  re.join re.esc( '`' ), *patterns, re.esc( '`' )
end


def backtick_quoted? string
  !string.is_a?( SourceString ) &&
  ( string[ 0 ] == '`' && string[ -1 ] == '`' )
end


def backtick_unquote string
  return string if string.is_a?( SourceString )
  
  if backtick_quoted? string
    SourceString.new string[ 1..-2 ]
  else
    string
  end
end


def unquote string
  if backtick_quoted? string
    backtick_unquote string
  elsif curly_quoted? string
    curly_unquote string
  else
    string
  end
end


BACKTICK_QUOTED_EXPR_RE = backtick_quote '[^\`]*'

STRING_REGEXP = /"([^"\\]*(\\.[^"\\]*)*)"|'([^'\\]*(\\.[^'\\]*)*)'/

INTEGER_REGEXPS = [/-?\d+/, /\d+/]
FLOAT_REGEXP = /-?\d*\.\d+/

EXPR_RE = re.or \
  QUOTED_STRING_RE,
  BACKTICK_QUOTED_EXPR_RE

EXPR_LIST_RE = re.join EXPR_RE, '(?:,\s*', EXPR_RE, ')*'

CURLY_QUOTED_CONSTANT = curly_quote( Names::Constant.pattern )


class SourceString < ::String; end


def expr? string
  case string
  when SourceString
    true
  else
    EXPR_RE =~ string
  end
end


def unary_ampersand_expr? source_string
  source_string.start_with? '&'
end


ParameterType \
  name: 'const',
  regexp: curly_quote( Names::Constant ),
  type: ::Object,
  transformer: ->( string ) {
    resolve_const curly_unquote( string )
  }


ParameterType \
  name: 'class',
  regexp: curly_quote( Names::Module ),
  type: Names::Module,
  transformer: ->( string ) { Names::Module.new curly_unquote( string ) }


ParameterType \
  name: 'attr',
  regexp: backtick_quote( Names::Attribute ),
  type: Names::Attribute,
  transformer: ->( string ){ Names::Attribute.new backtick_unquote( string ) }


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
  regexp: NRSER::Described.human_name_pattern,
  type: ::String,
  transformer: ->( string ){ string }


ParameterType \
  name: 'expr',
  regexp: EXPR_RE,
  type: SourceString,
  transformer: ->( raw_string ){ backtick_unquote raw_string }


ParameterType \
  name: 'value',
  regexp: [
    BACKTICK_QUOTED_EXPR_RE,
    # STRING_REGEXP,
    QUOTED_STRING_RE,
    *INTEGER_REGEXPS,
    CURLY_QUOTED_CONSTANT,
  ],
  type: ::Object,
  transformer: ->( string ) {
    case string
    # when nil
    #   binding.pry
    #   nil
    when BACKTICK_QUOTED_EXPR_RE
      eval backtick_unquote( string )
    # when STRING_REGEXP
    #   string.gsub( /\\"/, '"' ).gsub( /\\'/, "'" )
    when QUOTED_STRING_RE
      eval string
    when *INTEGER_REGEXPS
      string.to_i
    when FLOAT_REGEXP
      string.to_f
    when CURLY_QUOTED_CONSTANT
      resolve_const curly_unquote( string )
    else
      raise "SHOULDN'T BE HERE"
    end
  }
  

ParameterType \
  name: 'exprs',
  regexp: EXPR_LIST_RE,
  type: Array,
  transformer: ->( raw_string ) {
    raw_string.scan( EXPR_RE ).map &method( :backtick_unquote )
  }


ParameterType \
  name: 'param',
  regexp: backtick_quote( Names::Param ),
  type: Names::Param,
  transformer: ->( string ) { Names::Param.new backtick_unquote( string ) }
