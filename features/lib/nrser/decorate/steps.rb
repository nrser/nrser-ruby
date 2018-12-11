require 'nrser'
require 'nrser/ext/hash'
require 'nrser/decorate'

When "I create a new instance of `{word}`" do |name|
  @subject = @scope.const_get( name ).new
end

When "I create a new instance of `{word}` as `@{word}`" do |class_name, instance_name|
  @subject = @scope.const_get( class_name ).new
  instance_variable_set "@#{ instance_name }", @subject
end

When "I call `{word}`" do |name|
  @response = @subject.send name
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