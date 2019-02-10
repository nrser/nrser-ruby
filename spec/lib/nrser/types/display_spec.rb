require 'commonmarker'

SPEC_FILE(
  spec_path:        __FILE__,
  module:           NRSER::Types,
  description:      "Check examples in //lib/nrser/types/doc/display_table.md",
) do
  
  path = NRSER::ROOT.join 'lib', 'nrser', 'types', 'doc', 'display_table.md'
  source = path.read
  doc = CommonMarker.render_doc source, :DEFAULT, [ :table ]

  table_node = doc.walk.find { |node| node.type == :table }
  
  table_contents = table_node.each.map do |row|
    row.each.map do |col|
      col.first.string_content
    end
  end

  table_header = table_contents[0]
  table_body = table_contents[1..-1]

  hashes = table_body.map { |row|
    row.each_with_index.map { |contents, index|
      [ table_header[index], contents ]
    }.to_h
  }

  def t
    NRSER::Types
  end

  hashes.each do |hash|
    describe hash["source"] do
      subject { eval hash["source"] }

      hash.each do |col_name, value|
        if col_name.start_with? '#'
          method_name = col_name[1..-1].to_sym

          ATTRIBUTE method_name do
            it { is_expected.to eq value }
          end
        end
      end
    end
  end

end # SPEC_FILE