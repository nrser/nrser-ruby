#!/usr/bin/env ruby

require 'bundler/setup'

require 'commonmarker'
require 'nrser'
require 'pry'

def table_node
  path = NRSER::ROOT.join 'lib', 'nrser', 'types', 'doc', 'display_table.md'
  source = path.read

  doc = CommonMarker.render_doc source, :DEFAULT, [ :table ]

  doc.walk.find do |node|
    node.type == :table
  end
end

def table_contents
  @table_contents ||= table_node.each.map do |row|
    row.each.map do |col|
      col.first.string_content
    end
  end
end

def hashes
  table_header = table_contents[0]
  table_body = table_contents[1..-1]

  hashes = table_body.map { |row|
    row.each_with_index.map { |contents, index|
      [ table_header[index], contents ]
    }.to_h
  }
end

pry
