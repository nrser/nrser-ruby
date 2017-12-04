# Declarations
# =======================================================================

module NRSER; end
module NRSER::RSpex; end


# Definitions
# =======================================================================

# Just a namespace module where I stuck shared examples, with lil' utils to
# alias them to multiple string and symbol names if you like.
# 
module NRSER::RSpex::SharedExamples
  
  # Module (Class/self) Methods (Helpers)
  # =====================================================================
  
  # Shitty but simple conversion of natural string names to more symbol-y
  # ones.
  # 
  # @example
  #   name_to_sym 'expect subject'
  #   # => :expect_subject
  # 
  # @example
  #   name_to_sym 'function'
  #   # => :function
  # 
  # Doesn't do anything fancy-pants under the hood.
  # 
  # @param [String | Symbol] name
  # 
  # @return [Symbol]
  # 
  def self.name_to_sym name
    name.
      to_s.
      gsub( /\s+/, '_' ).
      gsub( /[^a-zA-Z0-9_]/, '' ).
      downcase.
      to_sym
  end
  
  
  # Bind a proc as an RSpec shared example to string and symbol names
  def self.bind_names proc, name, prefix: nil
    names = [name.to_s, name_to_sym( name )]
    
    unless prefix.nil?
      names << "#{ prefix } #{ name}"
      names << name_to_sym( "#{ prefix }_#{ name}" )
    end
    
    names.each do |name|
      shared_examples name, &proc
    end
  end
  
  
  # Shared Example Blocks and Binding
  # =====================================================================
  
  EXPECT_SUBJECT = ->( *expectations ) do
    merge_expectations( *expectations ).each { |state, specs|
      specs.each { |verb, noun|
        it {
          # like: is_expected.to(include(noun))
          is_expected.send state, self.send(verb, noun)
        }
      }
    }
  end # is expected
  
  bind_names EXPECT_SUBJECT, "expect subject"
  
  
  # Shared example for a functional method that compares input and output pairs.
  # 
  FUNCTION = ->( mapping: {}, raising: {} ) do
    mapping.each { |args, expected|
      # args = NRSER.as_array args
      
      # context "called with #{ args.map( &NRSER::RSpex.method( :short_s ) ).join ', ' }" do
      #   subject { super().call *args }
      describe_called_with *args do
        
        it {
          expected = unwrap expected, context: self
          
          matcher = if expected.respond_to?( :matches? )
            expected
          elsif expected.is_a? NRSER::Message
            expected.send_to self
          else
            eq expected
          end
          
          is_expected.to matcher
        }
      end
    }
    
    raising.each { |args, error|
      args = NRSER.as_array args
      
      context "called with #{ args.map( &NRSER::RSpex.method( :short_s ) ).join ', ' }" do
      # it "rejects #{ args.map( &:inspect ).join ', ' }" do
        it { expect { subject.call *args }.to raise_error( *error ) }
      end
    }
  end
  
  bind_names FUNCTION, 'function', prefix: 'a'
  
end # module NRSER::RSpex::SharedExamples
