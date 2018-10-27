# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# ========================================================================

module NRSER
module Ext


# Definitions
# =======================================================================

module Time
  
  # `#iso8601` with the `-` and `:` characters removed. Intended to be more
  # agreeable to a wider range of file systems and programs than the standard
  # format, while still adhering to ISO 8601 (as far as I can tell) and
  # acceptable to {Time.parse}.
  # 
  # There is nothing tricky about this method; I just wanted to standardize a
  # format for these situations. I *hate* reading date-times like this, but
  # it seems like the best and safest approach :/
  # 
  # @example
  #   time = Time.now
  #   
  #   time.iso8601
  #   # => "2018-04-19T03:00:30+08:00" # Nice, but potentially problematic
  #   
  #   Time.now.iso8601_for_files
  #   # => "20180419T030030+8000" # Fucking ugly, but easier on stupid systems
  # 
  # @return [String]
  # 
  def iso8601_for_idiots
    iso8601.gsub /\-\:/, ''
  end # #iso8601_for_idiots
  
end # module Time


# Namespace
# ========================================================================

end # module Ext
end # module NRSER
