##############################################################################
# RSpec helpers, shared examples, and other goodies.
# 
# This file is *not* required by default when `nrser` is since it **defines
# global methods** and is not needed unless you're in [Rspec][].
# 
# [Rspec]: http://rspec.info/
# 
##############################################################################


# Helpers
# =====================================================================

# Merge "expectation" hashes by appending all clauses for each state.
# 
# @example
#   
# 
# @param [Array<Hash>] *expectations
#   Splat of "expectation" hashes - see the examples.
# 
def merge_expectations *expectations
  Hash.new { |result, state|
    result[state] = []
  }.tap { |result| 
    expectations.each { |ex|
      ex.each { |state, clauses|
        result[state] += clauses.to_a
      }
    }
  }
end


# Refine the subject of the parent scope by `#send`ing it a message and setting
# the result as the new subject.
# 
# @param [Symbol | String] method_name
#   Name of the method to send to.
# 
# @param [Array] args*
#   Arguments to send to the method.
# 
# @return [void]
#   Seems to be what RSpec's `subject` method returns.
# 
def refine_subject method_name, *args
  subject {
    super().send method_name, *args
  }
end # #refine_subject


# Shared Examples
# =====================================================================

shared_examples "expect subject" do |*expectations|
  merge_expectations( *expectations ).each { |state, specs|
    specs.each { |verb, noun|
      it {
        # like: is_expected.to(include(noun))
        is_expected.send state, self.send(verb, noun)
      }
    }
  }
end # is expected


# Shared example for a functional method that compares input and output pairs.
# 
shared_examples "function" do |success: {}, error: {}|
  success.each { |args, expected|
    args = NRSER.as_array args
    
    context "called with #{ args.map( &:inspect ).join ', ' }" do
      subject { super().call *args }
      
      it {
        matcher = if expected.respond_to?( :matches? )
          expected
        else
          eq expected
        end
        
        is_expected.to matcher
      }
    end
  }
end # function
