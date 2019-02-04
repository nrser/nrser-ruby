require 'pp'

def Pipeline
  def << value
  
  end
end


module Enumerable
  def yield_map &block
    each_with_object( [] ) { |entry, array|
      block.call( entry ) { |*yielded| array << yielded }
    }
  end
  
  def ym2 &block
    pipeline do |entry, writer|
      block.call( entry ) { |value| writer << value }
    end
  end
end


result = { a: [ 1, 2 ], b: 3 }.yield_map { |(key, value), &yielder|
  if value.is_a? Array
    value.each { |inner_value| yielder.call key, inner_value }
  else
    yielder.call key, value
  end
}

pp result
