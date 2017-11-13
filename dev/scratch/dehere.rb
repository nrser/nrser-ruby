
module NRSER
  # @!group Text
  
  # An attempt to "just fix the indentation" in multi-line strings with 
  # interpolation:
  # 
  #     <<-END
  #       Here's some stuff:
  #       
  #           #{ stuff.pretty_inspect }
  #       
  #       And we're back...
  #       
  #     END
  # 
  # I *don't think this is possible* - I don't see a way to differentiate 
  # when we leave the context of the interpolated lines (from `#pretty_inspect`
  # above) and when the interpolated context just reaches an indent level 
  # that is equal to the non-interpolated text.
  # 
  # So this was moved over to `dev/scratch` as a reminder / reference to what
  # and why it failed.
  # 
  def self.dehere text
    lines = text.lines.drop_while { |line| line =~ /\A\s*\z/ }
    
    initial_indent = lines.first[/\A[\ \t]+/]
    relative_indent = ''
    
    
    puts "initial indent is #{ initial_indent.inspect }"
    
    lines.map { |line|
      puts "mapping #{ line.inspect }..."
      
      # See if the string starts with the initial indent
      if line.start_with? initial_indent
        # It does, so chop that off the front.
        without_initial_indent = line[initial_indent.length..-1]
        
        # Now set the relative indent in case we need it next iteration
        relative_indent = without_initial_indent[/\A[\ \t]+/]
        
        without_initial_indent
        
      else
        # The line *does not* start with the initial indent, so we assume it 
        # was interpolated in and should have the most recent relative indent
        # applied to it.
        relative_indent + line
      end
    }.join
  end # .dehere
    
end # module NRSER
