# frozen_string_literal: true

module NRSER
  
  # @!group String Functions
  # ==========================================================================
  
  def self.filter_repeated_blank_lines str, remove_leading: false
    out = []
    lines = str.lines
    skipping = remove_leading
    str.lines.each do |line|
      if line =~ /^\s*$/
        unless skipping
          out << line
        end
        skipping = true
      else
        skipping = false
        out << line
      end
    end
    out.join
  end # .filter_repeated_blank_lines
  
  
  def self.lazy_filter_repeated_blank_lines source, remove_leading: false
    skipping = remove_leading
    
    source = source.each_line if source.is_a? String
    
    Enumerator::Lazy.new source do |yielder, line|
      if line =~ /^\s*$/
        unless skipping
          yielder << line
        end
        skipping = true
      else
        skipping = false
        yielder << line
      end
    end
    
  end # .lazy_filter_repeated_blank_lines
  
  
 
  
  # @!endgroup String Functions
  
end # module NRSER
