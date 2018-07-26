module NRSER
  
  # Format a segment of a message.
  # 
  # If `segment` responds to `#to_summary`, it will be called and the
  # result will be returned.
  # 
  # Strings are simply returned. Other things are inspected (for now).
  # 
  # @param [Object] segment
  #   The segment.
  # 
  # @return [String]
  #   The formatted string for the segment.
  # 
  def self.fmt_msg_segment segment
    return segment.to_summary.to_s if segment.respond_to?( :to_summary )
    
    return segment if String === segment
    
    # TODO  Do better!
    segment.inspect
  end

  
  # Provides simple formatting for messages constructed as a list of 
  # segments.
  # 
  # Allows you to do this sort of thing:
  # 
  #     NRSER.fmt_msg "Some stuff went wrong with the", thing,
  #       "and we're figuring it out, sorry. Maybe take a look at",
  #       something_else
  # 
  # Which I find easier than interpolation since you quite often have to split
  # across lines anyways.
  # 
  # See {.fmt_msg_segment} for info about how each segment is formatted.
  # 
  # This methods joins the results together 
  # 
  # @param [Array] *message
  #   Message segments.
  # 
  # @return [String]
  #   Formatted and joined message ready to pass up to the built-in
  #   exception's `#initialize`.
  # 
  def self.fmt_msg *segments
    segments.map { |segment| fmt_msg_segment segment }.join( ' ' )
  end # .words
  
end # module NRSER
