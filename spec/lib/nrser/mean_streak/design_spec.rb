# encoding: UTF-8
# frozen_string_literal: true

describe_spec_file(
  spec_path: __FILE__,
  class: NRSER::MeanStreak,
) do
  
  describe "Test instance (`*...*` => `<I>...</I>`, etc. replacements)" do
    subject {
      described_class.new do |ms|
        ms.render_type :emph do |doc, node|
          "<I>#{ doc.render_children( node ) }</I>"
        end
        
        ms.render_type :strong do |doc, node|
          "<B>#{ doc.render_children( node ) }</B>"
        end
        
        ms.render_type :code do |doc, node|
          "<C>#{ node.string_content }</C>"
        end
        
        # ms.render_type :code do |doc, prev_node, source_before, node, source_after, next_node|
        #   [
        #     source_before.chomp( '`' ),
        #     "C#{ node.string_content }/C",
        #     source_after.lchomp( '`' ),
        #   ]
        # end
      end
    }
  
    describe_method :render do
      it_behaves_like "function",
        mapping: {
          # No handled nodes
          "Here I am" => "Here I am",
          
          # Simple `:emph`, `:strong` with just a text child
          "Here *I* am" => "Here <I>I</I> am",
          "**Here** *I* am" => "<B>Here</B> <I>I</I> am",
          
          # Nested `:emph` / `:strong`
          "*Here **I** am*" => "<I>Here <B>I</B> am</I>",
          
          # `:code`
          "Here `I` am" => "Here <C>I</C> am",
          # At the start
          "`Here I` am" => "<C>Here I</C> am",
          # At the end
          "Here `I am`" => "Here <C>I am</C>",
          
          # Some big ol' bytes
          "北京东城东直门" => "北京东城东直门",
          "北京*东城*东直门" => "北京<I>东城</I>东直门",
          
          # Nesty-messtys with `:code` blocks...
          # 
          # It turns out the way to include ` in inline code is to quote
          # with more than the longest backtick run inside
          # 
          %{A string: ``"with `backticks` in it"``} =>
            %{A string: <C>"with `backticks` in it"</C>}
        }
    end
  end
end
