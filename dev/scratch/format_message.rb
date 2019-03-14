# From the code...

raise TypeError.new \
  "`target:` arg must be a:", Decoration, UnboundMethod, Method,
  target: target

# kinda want..?
# 
# `target:` arg must be a: {Decoration}, {UnboundMethod} or {Method}
# 
# # Context
# 
#     target : {Hash} = { x: 1, y: 2 }
#

# So how do you make that nice list shit work?

kwd( :target ), "arg must be a", or( Decoration, UnboundMethod, Method )

# ok, this is nicer
kwd( :target ), "arg must be a", list( Decoration, UnboundMethod, or: Method )

# so... how does that work?




class Doc
  def initialize &block
    @block = block
  end
  
  def list *args, **kwds
    string = args.map( &:to_s ).join ', '
    
    if kwds.key?( :and ) && kwds.key?( :or )
      string += " and/or #{ kwds[ :and ] }"
    if kwds.key( :and )
      string += " and #{ kwds[ :and ] }"
    elsif kwds( :or )
      string += " and #{ kwds[ :or ] }"
    end
    
    string
  end
  
  def to_s
    instance_exec @block
  end
end


class MyError
  def initialize &block
    super( Doc.new( &block ).to_s )
  end
end


raise MyError.new( target: target ) {[
  kwd( :target ), "arg must be a",
  list( Decoration, UnboundMethod, or: Method )
]}


# When you don't want spaces (because of punctuation :/):

"It is an", A, ", or it's not."
  