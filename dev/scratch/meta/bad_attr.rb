class BadAttr
  attr_accessor :BAD

  def initialize bad
    @BAD = bad
  end
end

bad = BadAttr.new 'bad...'

puts bad.BAD

bad.BAD = 'worse!'

puts bad.BAD

