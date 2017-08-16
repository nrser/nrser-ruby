module NRSER 
  class << self
    def format_exception e
      "#{ e.message } (#{ e.class }):\n  #{ e.backtrace.join("\n  ") }"
    end
  end # class << self
end # module NRSER
