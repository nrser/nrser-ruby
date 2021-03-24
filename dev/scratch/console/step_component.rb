require 'nrser/described/cucumber/step_component/expression'
require 'nrser/described/cucumber/step_component/sequence'
require 'nrser/described/cucumber/step_component/variations'

Expression = NRSER::Described::Cucumber::StepComponent::Expression
Composite = NRSER::Described::Cucumber::StepComponent::Composite
Sequence = NRSER::Described::Cucumber::StepComponent::Sequence
Variations = NRSER::Described::Cucumber::StepComponent::Variations


def make_exp name
  Expression.new name.to_sym, "#{ name } Exp" do |arg|
    [ "#{ name } received #{ arg }" ]
  end
end


def make_exps prefix, count
  count.times.map { |i|
    make_exp "#{ prefix }_#{ i + 1 }"
  }
end


def show comp
  comp.map { |e| e.map &:name }
end


COUNTS = { A: 2, B: 2 }

EXPS = COUNTS.map { |prefix, count|
  [ prefix, make_exps( prefix, count ) ]
}.to_h

VARS = EXPS.map { |prefix, exps|
  # Variations.new prefix, *exps
  exps.reduce :|
}

# S = Sequence.new :S, *VARS
S_1 = VARS.reduce :+

COUNTS_2 = {
  A: 1,
  B: 3,
  C: 2,
  D: 2,
}

EXPS_2 = COUNTS_2.map { |n, c| [ n, make_exps( n, c ) ] }.to_h

VARS_2 = EXPS_2.map { |n, exps| exps.reduce :| }

S_2 = VARS_2.reduce :+
