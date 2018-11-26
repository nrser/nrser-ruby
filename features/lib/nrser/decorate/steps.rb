require 'nrser'
require 'nrser/ext/hash'
require 'nrser/decorate'

Given "a class:" do |string|
  @scope = Module.new
  @scope.class_eval string
end

When "I create a new instance of `{word}`" do |name|
  @instance = @scope.const_get( name ).new
end

When "call `{word}`" do |name|
  @response = @instance.send name
end

Then "the response includes:" do |*args|
  table = args[0]
  
  table.rows.each do |(key, value)|
    key_path = key.split( '.' ).map &:to_sym
    expect( @response.dig *key_path ).to eq eval( value )
  end
end

Then "it responds with {string}" do |string|
  expect( @response ).to eq string
end

Then "it responds with:" do |string|
  expect( @response ).to eq ~string
end