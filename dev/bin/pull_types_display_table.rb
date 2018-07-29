#!/usr/bin/env ruby

require 'bundler/setup'

require 'nrser'
require 'nokogiri'
require 'net/https'
require 'uri'
require 'json'
require 'pp'
require 'fileutils'
require 'pry'


token = ARGV[0] || ENV['QUIP_API_TOKEN']

unless token
  raise "Must provide Quip API token as first arg or in QUIP_API_TOKEN env var"
end

$tmp_dir = NRSER::ROOT.join 'tmp', 'display_table'

FileUtils.mkdir_p $tmp_dir unless $tmp_dir.exist?

def save_tmp filename, contents
  path = $tmp_dir.join filename
  path.write contents
  puts "[Temp save to #{ path }]"
end

id = 'iBBRAuEZyxui'
url = "https://platform.quip.com/1/threads/#{ id }"
uri = URI.parse url

http = Net::HTTP.new uri.host, uri.port
http.use_ssl = true
request = Net::HTTP::Get.new uri.to_s
request.initialize_http_header "Authorization" => "Bearer #{ token }"

response = http.request request
quip_doc = JSON.load response.body
html_doc = Nokogiri::HTML quip_doc["html"]

html_table = html_doc.at 'table'

# save_tmp 'table.html', html_table.to_s

# Remove funky unicode whitespace that Quip uses...
def normalize text
  text.gsub( "\u200B", "" ).gsub( "\u00A0", " " )
end

all_rows = html_table.search( 'tr' ).map do |tr|
  tr.search( 'th, td' ).map do |cell|
    span = cell.at 'span'
    span.css( 'br' ).each { |node| node.replace "\n" }
    normalize span.text
  end
end

# remove empty rows
all_rows.reject! { |row|
  row.all? { |cell| /\A[[:space:]]*\z/ =~ cell }
}

header_row = all_rows[0]

$col_maxes = (0...header_row.length).map { |col_index|
  all_rows.reduce( 0 ) { |max, row|
    [max, row[col_index].length].max
  }
}

$md_rows = []

def add_md_row row
  $md_rows << '| ' + row.each_with_index.map { |col, index|
    "`#{ col }`#{ ' ' * ($col_maxes[index] - col.length + 2) }"
  }.join( ' | ' ) + ' |'
end

add_md_row header_row

$md_rows << '| ' + $col_maxes.map { |count| '-' * (count + 4) }.join( ' | ') + ' |'

body_rows = all_rows[1..-1]

body_rows.each { |row| add_md_row row }

md_path = NRSER::ROOT.join 'lib', 'nrser', 'types', 'doc', 'display_table.md'

md = md_path.read
md_lines = md.lines
start_index = md_lines.index { |line| line.start_with? '| ' }

new_md_lines = md_lines[0...start_index] + $md_rows.map { |row| row + "\n" }

md_path.write new_md_lines.join
