module NRSER
  # @!group Path Functions
  
  # @return [Pathname]
  # 
  def self.pn_from path
    if path.is_a? Pathname
      path
    else
      Pathname.new path
    end
  end
  
  
  # Get the directory for a path - if the path is a directory, it's returned
  # (converted to a {Pathname}). It's not a directory, it's {Pathname#dirname}
  # will be returned.
  # 
  # Expands the path (so that `~` paths work).
  # 
  # @param [String | Pathname] path
  #   File or directory path.
  # 
  # @return [Pathname]
  #   Absolute directory path.
  # 
  def self.dir_from path
    pn = pn_from( path ).expand_path
    
    if pn.directory?
      pn
    else
      pn.dirname
    end
  end # .dir_from
  
  
  # @todo Document glob? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.looks_globish? path
    %w|* ? [ {|.any? &path.to_s.method( :include? )
  end # .glob?
  
  
  # Ascend the directory tree starting at `from` (defaults to working
  # directory) looking for a relative path.
  # 
  # How it works and what it returns is dependent on the sent options.
  # 
  # In the simplest / default case:
  # 
  # 1.
  # 
  # @param [String | Pathname] rel_path
  #   Relative path to search for. Can contains glob patterns; see the `glob`
  #   keyword.
  # 
  # @param [String | Pathname] from:
  #   Where to start the search. This is the first directory checked.
  # 
  # @param [Boolean | :guess] glob:
  #   Controls file-glob behavior with respect to `rel_path`:
  #   
  #   -   `:guess` (default) - boolean value is computed by passing `rel_path`
  #       to {.looks_globish?}.
  #       
  #   -   `true` - {Pathname.glob} is used to search for `rel_path` in each
  #       directory, and the first glob result that passes the test is
  #       considered the match.
  #       
  #   -   `false` - `rel_path` is used as a literal file path (if it has a `*`
  #       character it will only match paths with a literal `*` character,
  #       etc.)
  #   
  #   **Be mindful that glob searches can easily consume significant resources
  #   when using broad patterns and/or large file trees.**
  #   
  #   Basically, you probably don't *ever* want to use `**` - we walk all the
  #   way up to the file system root, so it would be equivalent to searching
  #   *the entire filesystem*.
  # 
  # @todo
  #   There should be a way to cut the search off early or detect `**` in
  #   the `rel_path` and error out or something to prevent full FS search.
  # 
  # @param [Symbol] test:
  #   The test to perform on pathnames to see if they match. Defaults to
  #   `:exist?` - which calls {Pathname#exist?} - but could be `:directory?`
  #   or anything else that makes sense.
  # 
  # @param [Symbol] result:
  #   What information to return:
  #   
  #   -   `:common_root` (default) - return the directory that the match was
  #       relative to, so the return value is `from` or a ancestor of it.
  #       
  #   -   `:path` - return the full path that was matched.
  #   
  #   -   `:pair` - return the `:common_root` value followed by the `:path`
  #       value in a two-element {Array}.
  # 
  # @return [nil]
  #   When no match is found.
  # 
  # @return [Pathname]
  #   When a match is found and `result` keyword is
  #   
  #   -   `:common_root` - the directory in `from.ascend` the match was made
  #       from.
  #       
  #   -   `:path` - the path to the matched file.
  # 
  # @return [Array<(Pathname, Pathname)>]
  #   When a match is found and `result` keyword is `:pair`, the directory
  #   the match was relative to followed by the matched path.
  # 
  def self.find_up(
    rel_path,
    from: Pathname.pwd,
    glob: :guess,
    test: :exist?,
    result: :common_root
  )
    # If `glob` is `:guess`, override `glob` with the result of
    # {.looks_globish?}
    # 
    glob = looks_globish?( rel_path ) if glob == :guess
    
    found = pn_from( from ).ascend.find_map { |dir|
      path = dir / rel_path
      
      found_path = if glob
        Pathname.glob( path ).find { |match_path|
          match_path.public_send test
        }
      elsif path.public_send( test )
        path
      else
        nil
      end
      
      unless found_path.nil?
        [dir, found_path]
      end
    }
    
    return nil if found.nil?
    
    dir, path = found
    
    Types.match result,
      :common_root, dir,
      :pair, found,
      :path, path
  end
  
  
  # Exactly like {NRSER.find_up} but raises if nothing is found.
  # 
  def self.find_up! *args
    find_up( *args ).tap { |result|
      if result.nil?
        raise "HERE! #{ args.inspect }"
      end
    }
  end
  
  
end # module NRSER
