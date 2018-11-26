When "a class with:" do |src|
  @subject = Class.new
  @subject.class_eval src
end

When "I create a new instance" do
  @subject = @subject.new
end

When "call {word}" do |name|
  @subject = @subject.send name
end

Then "it should respond {string}" do |response|
  expect( @subject ).to eq response
end


Given("a color {word}") do |color|
  @color = color
end

Given("a number {int}") do |int|
  @number = number
end

When("I count one for each test") do
  $count ||= 0
  $count += 1
end

Then("the final count should be {int}") do |int|
  expect( $count ).to be int
end

def gen_table table
  [ 'red', 'blue', ].product( [ 3, 4 ] ).each do |color, number|
    table << [ color, number ]
  end
  table
end
