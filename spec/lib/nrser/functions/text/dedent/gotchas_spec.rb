require 'nrser/ext/string'

SPEC_FILE(
  description: "Gotchas",
  spec_path: __FILE__,
  instance_method: 'NRSER::Ext::String#dedent',
) do
  
  CASE "Newline literals in HEREDOCs" do
  # ========================================================================
    
    subject do
      super().bind( input ).call
    end
    
    WHEN "when a HEREDOC has a with literal \\n" do
    # ========================================================================
      
      let :input do
        <<-END
          <%= headline %>
          
          <% errors.each_with_index do |error, index| %>
          <%= (index.succ.to_s + ".").ljust( 3 ) %> <%= error.message %> (<%= error.class %>):
              <%= error.backtrace.join( "\n" ) %>
          <% end %>
          
        END
      end
      
      it "should NOT produce the desired dedent" do
        expect( subject.lines.first ).not_to match /\A\S+/
      end
      
    end
    # ************************************************************************
    
    
    WHEN "when the HEREDOC uses $/ instead of \\n" do
      let :input do
        <<-END
          <%= headline %>
          
          <% errors.each_with_index do |error, index| %>
          <%= (index.succ.to_s + ".").ljust( 3 ) %> <%= error.message %> (<%= error.class %>):
              <%= error.backtrace.join( $/ ) %>
          <% end %>
          
        END
      end
      
      it "should produce the desired dedent" do
        expect( subject.lines.first ).to match /\A\S+/
      end
      
    end # WHEN "when the HEREDOC uses $/ instead of \\n" Description
    
  end # CASE Newline literals in HEREDOCs
  # ************************************************************************
  
end # SPEC_FILE
  