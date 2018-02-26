# frozen_string_literal: true

# Requirements
# =======================================================================

# Stdlib
# -----------------------------------------------------------------------
require 'pathname'
require 'open3'


# Definitions
# =======================================================================

module NRSER
  # Get the absolute path to the root directory of the Git repo that
  # `path` is in.
  # 
  # @note
  #   In submodules, this will return the root of the submodule, **NOT**
  #   of the top-level repo.
  # 
  # @param [String | Pathname] path
  #   Path in Git repo that you want to find the root of.
  #   
  #   Accepts relative and user (`~/...`) paths.
  # 
  # @return [Pathname]
  # 
  def self.git_root path = Pathname.getwd
    dir = dir_from path
    
    out, err, status = Open3.capture3 \
      'git rev-parse --show-toplevel',
      chdir: dir.to_s
    
    if status != 0
      message = \
        "#{ path.to_s.inspect } does not appear to be in a Git repo\n\n" +
        NRSER::Char::NULL.replace( err ) + "\n"
      
      raise SystemCallError.new message, status.exitstatus
    end
    
    Pathname.new out.chomp
  end
  
end
