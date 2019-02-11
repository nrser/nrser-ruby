# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  Described
module  RSpec
module  ExampleGroup


# Definitions
# =======================================================================

# Assorted useful shot, mostly to help debugging...
# 
module Helpers
  
  def type?
    metadata.key? :type
  end
  
  
  def abs_file_path cwd = Dir.getwd
    File.expand_path metadata[ :file_path ], cwd
  rescue
    nil
  end
  
  
  def source_location
    Meta::Source::Location.new [ abs_file_path, metadata[ :line_number ] ]
  end
  
  
  def summary
    name = if metadata.key? :described
      metadata[ :described ].class.name.sub /\ANRSER\:\:/, ''
    elsif metadata.key? :type
      metadata[ :type ].to_s.upcase
    else
      "ExampleGroup"
    end
    
    "{#{ name }@#{ source_location }}"
  end
  
  
  def to_s
    summary
  end

end # module Helpers


# /Namespace
# =======================================================================

end # module  ExampleGroup
end # module  RSpec
end # module  Described
end # module  NRSER
