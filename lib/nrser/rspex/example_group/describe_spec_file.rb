# frozen_string_literal: true

module NRSER::RSpex::ExampleGroup
  
  # **EXPERIMENTAL**
  # 
  # Example group helper for use at the top level of each spec file to
  # set a bunch of stuff up and build a helpful description.
  # 
  # @todo
  #   This is totally just a one-off right now... would need to be
  #   generalized quite a bit...
  #   
  #   1.  Extraction of module, class, etc from metadata should be flexible
  #       
  #   2.  Built description would need to be conditional on what metadata
  #       was found.
  # 
  # @param [String] description:
  #   A description of the spec file to add to the RSpec description.
  # 
  # @param [String] spec_path:
  #   The path to the spec file (just feed it `__FILE__`).
  #   
  #   Probably possible to extract this somehow without having to provide it?
  # 
  # @return [nil]
  # 
  def describe_spec_file  description: nil,
                          spec_path:,
                          bind_subject: true,
                          **metadata,
                          &body
    
    if metadata[:module] && metadata[:method]
      meth = metadata[:module].method metadata[:method]
      file, line = meth.source_location
      path = Pathname.new file
      loc = "./#{ path.relative_path_from Pathname.getwd }:#{ line }"
      
      spec_rel_path = \
        "./#{ Pathname.new( spec_path ).relative_path_from Pathname.getwd }"
      
      desc = [
        "#{ metadata[:module].name }.#{ metadata[:method] }",
        "(#{ loc })",
        description,
        "Spec (#{ spec_rel_path})"
      ].compact.join " "
      
      subj = meth
    
    elsif metadata[:class]
      klass = metadata[:class]
      
      if metadata[:instance_method]
        instance_method = klass.instance_method metadata[:instance_method]
        
        file, line = instance_method.source_location
        
        name = "#{ klass.name }##{ metadata[:instance_method] }"
        
      elsif metadata[:method]
        # Class method
        meth = metadata[:class].method metadata[:method]
        file, line = meth.source_location
        path = Pathname.new file
        loc = "./#{ path.relative_path_from Pathname.getwd }:#{ line }"

        spec_rel_path = \
          "./#{ Pathname.new( spec_path ).relative_path_from Pathname.getwd }"

        desc = [
          "#{ metadata[:class].name }.#{ metadata[:method] }",
          "(#{ loc })",
          description,
          "Spec (#{ spec_rel_path})"
        ].compact.join " "

        subj = meth
        
      else
        name = klass.name
        
        # Get a reasonable file and line for the class
        file, line = klass.
          # Get an array of all instance methods, excluding inherited ones
          # (the `false` arg)
          instance_methods( false ).
          # Add `#initialize` since it isn't in `#instance_methods` for some
          # reason
          <<( :initialize ).
          # Map those to their {UnboundMethod} objects
          map { |sym| klass.instance_method sym }.
          # Toss any `nil` values
          compact.
          # Get the source locations
          map( &:source_location ).
          # Get rid of `[nil, nil]` results, which seems to come from C exts
          reject { |(path, line)| path.nil? || line.nil? }.
          # Get the first line in the shortest path
          min_by { |(path, line)| p [path, line]; [path.length, line] }
          
          # Another approach I thought of... (untested)
          # 
          # Get the path
          # # Get frequency of the paths
          # count_by { |(path, line)| path }.
          # # Get the one with the most occurrences
          # max_by { |path, count| count }.
          # # Get just the path (not the count)
          # first
      end
      
      location = if file
        "(#{ NRSER::RSpex.dot_rel_path file }:#{ line })"
      end
      
      desc = [
        "𝑆𝑃𝐸𝐶 𝐹𝐼𝐿𝐸 `#{ NRSER::RSpex.dot_rel_path spec_path }` 𝐹𝑂𝑅",
        name,
        location,
        description,
      ].compact.join " "
      
      subj = klass
      
    else
      # TODO  Make this work!
      raise ArgumentError.new binding.erb <<-END
        Not yet able to handle metadata:
        
            <%= metadata.pretty_inspect %>
        
      END
    end
    
    describe desc, **metadata do
      if bind_subject
        subject { subj }
      end
      
      module_exec &body
    end
    
    nil
  end # #describe_spec_file
  
end # module NRSER::RSpex::ExampleGroup
