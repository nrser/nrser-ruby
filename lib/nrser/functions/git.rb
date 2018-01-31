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
  def self.git_root from
    path = Pathname.new( from ).expand_path
    path = path.dirname unless path.directory?
    
    out, err, status = Open3.capture3 \
      'git rev-parse --show-toplevel',
      chdir: path.to_s
    
    if status != 0
      message = \
        "#{ path.to_s.inspect } does not appear to be in a Git repo\n\n" +
        NRSER::Char::NULL.replace( err ) + "\n"
      
      raise SystemCallError.new message, status.exitstatus
    end
    
    out.chomp
  end
end
