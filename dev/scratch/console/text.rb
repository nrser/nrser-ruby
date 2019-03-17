# encoding: UTF-8

require 'nrser/text'

def build &block
  puts NRSER::Text.build( &block ).render
end

def uni
  𝑎 = 123
  puts 𝑎 + 1
end


require "concurrent/map"

def resolve_shit
  puts "Resolving shit in thread #{ Thread.current.name }..."
  10.times do |i|
    sleep 1
    puts "Shit slept #{ i } in thread #{ Thread.current.name }"
  end
  # require 'rspec'
  
  puts "Resolved in thread #{ Thread.current.name }"
  "shit"
end

def slam_map pre_fill: false
  map = Concurrent::Map.new
  key = :bull
  
  start = Time.now
  
  if pre_fill
    map.compute_if_absent( key ) { resolve_shit }
  end
  
  threads = 10.times.map do |i|
    Thread.new do
      Thread.current.name = i.to_s
      value = map.compute_if_absent( key ) { resolve_shit }
      puts "Thread #{ i } got #{ key } => #{ value }\n"
    end
  end
  
  threads.each &:join
  
  puts "Time: #{ Time.now - start }"
  
  nil
end
  
