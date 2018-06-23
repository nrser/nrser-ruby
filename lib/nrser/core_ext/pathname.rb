require 'pathname'

class Pathname
  
  # override to accept Pathname instances.
  # 
  # @param [String] *prefixes
  #   the prefixes to see if the Pathname starts with.
  # 
  # @return [Boolean]
  #   true if the Pathname starts with any of the prefixes.
  # 
  def start_with? *prefixes
    to_s.start_with? *prefixes.map { |prefix|
      if Pathname === prefix
        prefix.to_s
      else
        prefix
      end
    }
  end
  
  
  alias_method :_original_sub, :sub
  
  
  # override sub to support Pathname instances as patterns.
  # 
  # @param [String | Regexp | Pathname] pattern
  #   thing to replace.
  # 
  # @param [String | Hash] replacement
  #   thing to replace it with.
  # 
  # @return [Pathname]
  #   new Pathname.
  # 
  def sub pattern, replacement
    case pattern
    when Pathname
      _original_sub pattern.to_s, replacement
    else
      _original_sub pattern, replacement
    end
  end


  # Just returns `self`. Implemented to match the {String#to_pn} API so it
  # can be called on an argument that may be either one.
  # 
  # @return [Pathname]
  # 
  def to_pn
    self
  end
  
  
  # See {NRSER.find_up}.
  # 
  def find_up rel_path, **kwds
    NRSER.find_up rel_path, **kwds, from: self
  end # #find_root
  
  
  # See {NRSER.find_up!}.
  # 
  def find_up! rel_path, **kwds
    NRSER.find_up! rel_path, **kwds, from: self
  end # #find_root
  
  
  # Shortcut to convert into a relative pathname, by default from the working
  # directory, with option to `./` prefix.
  # 
  # @param [Pathname] base_dir:
  #   Directory you want the result to be relative to.
  # 
  # @param [Boolean] dot_slash:
  #   When `true` will prepend `./` to the resulting path, unless it already
  #   starts with `../`.
  # 
  # @return [Pathname]
  # 
  def to_rel base_dir: Pathname.getwd, dot_slash: false
    rel = relative_path_from base_dir
    
    if dot_slash && !rel.start_with?( /\.\.?\// )
      File.join( '.', rel ).to_pn
    else
      rel
    end
  end
  
  
  # Just a quick cut for `.to_rel.to_s`, since I seem to use that sort of form
  # a lot.
  # 
  # @param (see #to_rel)
  # 
  # @return [String]
  # 
  def to_rel_s *args
    to_rel( *args ).to_s
  end
  
end # class Pathname
