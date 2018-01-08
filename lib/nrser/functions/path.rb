module NRSER
  # @!group Path Functions
  
  GLOB_RE = /
    (?:[^\\][\*\?]) |
    (?:[^\\]\[)
  /x
  
  
  def self.pn_from path
    if path.is_a? Pathname
      path
    else
      Pathname.new path
    end
  end
  
  
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
  
  
  # @todo Document glob? method.
  # 
  # @param [type] arg_name
  #   @todo Add name param description.
  # 
  # @return [return_type]
  #   @todo Document return value.
  # 
  def self.glob? path
    
  end # .glob?
  
  
  def self.find_parent_dir from: Pathname.pwd, strict: false, &block
    from = Pathname.new( from ) unless from.is_a?( Pathname )
    
    pn_from( from ).ascend.find
    
    unless strict
      result = block.call from
      return result if result
    end
    
    parent = from.parent
    
    return nil if from == parent
    
    find_parent_dir from: parent, strict: false, &block
  end
  
  
  def self.parent_dir_containing(
    rel_path,
    from: Pathname.pwd,
    strict: false,
    glob: :guess
  )
    glob = looks_globish?( rel_path ) if glob == :guess
    
    find_parent_dir from, strict: strict do |parent|
      path = parent / rel_path
      
      found = if glob
        # TODO  This should actually be open to performance improvement since
        #       we don't actually need the results, we just care if there are
        #       *any* results, which would allow us to short-circuit after
        #       finding one, and might change optimal search strategy.
        #       
        #       However, globbing looks like it's fairly involved process in C,
        #       which is probably already quite optimized and involved to
        #       copy and modify.
        #       
        ! Pathname.glob( path ).empty?
      else
        path.exist?
      end
      
      if found
        parent
      else
        nil
      end
    end
  end
  
end # module NRSER
