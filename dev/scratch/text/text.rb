Text.build do
  p "Do some", i( stuff ), ":",
    ruby( "array = [ :a, :b, :c, :d ]",
          "hash = { a: 1, b: 2, c: 3, d: 4 }" ),
    
end

__END__
Do some *stuff*: `array = [ :a, :b, :c, :d ]`
