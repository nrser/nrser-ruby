# encoding: UTF-8
# frozen_string_literal: true


# Namespace
# =======================================================================

module  NRSER
module  RSpex
module  ExampleGroup


# Definitions
# =======================================================================

# Add {NRSER::Log} logging support to example group classes. 
# 
# This is custom (versus including {NRSER::Log::Mixin}) for a few reasons:
# 
# 1.  Example group class names are huge long messes, so we don't want to use 
#     them for logger names.
#     
# 2.  I'm not sure how well {NRSER::Log::Mixin} will work when included in a
#     module that is included in another module that is extended (I think?) into
#     a class. Yeah, it should be made to work, but I doubt it just does.
#     
# 3.  It uses the new "instance named tags" logger stuff. It's the first thing,
#     and instance named tag support was written for it, so that hasn't been 
#     integrated in {NRSER::Log::Mixin} yet.
# 
module Logger

  # Get the logging "named tag" for this example group class in specific.
  #
  # This is merged with the named tags of ancestor example groups in
  # {#logger_metadata_named_tags} to form the
  # {NRSER::Log::Logger#instance_named_tags} assigned to loggers dynamically
  # created in {#logger}.
  # 
  # @return [Hash<String, String>]
  #
  def logger_description_named_tag
    # if !respond_to?( :metadata ) || metadata.nil? || metadata[ :type ].nil?
    #   return {}
    # end

    key = if metadata[ :type ]
      metadata[ :type ].to_s.upcase
    else
      'DESCRIBE'
    end

    value = case metadata[ :type ]
    when :attribute
      "##{ metadata[ :attribute_name ] }"
    when :called_with
      metadata[ :called_with_args ].to_desc
    when :module
      metadata[ :module ].n_x.safe_name
    when :class
      metadata[ :class ].n_x.safe_name
    when :instance_method
      "##{ metadata[ :method_name ] }"
    when :spec_file
      metadata[ :spec_rel_path ]
    else
      # binding.pry
      if metadata[ :x_description ]
        metadata[ :x_description ].joined
      else
        description
      end
    end

    { key => value }
  end


  # Get logging "named tags" (key/value tag pairs) for the example group class'
  # ancestors.
  # 
  # @return [::Hash<String, String>]
  #   Will be empty unless the superclass is a {RSpec::Core::ExampleGroup}
  #   subclass that responds to `#logger_metadata_named_tags`.
  # 
  def logger_super_metadata_named_tags
    # Cut-off condition (any of):
    # 
    # 1.  No superclass (it's `nil`).
    #     
    # 2.  Superclass is not a proper subclass of {RSpec::Core::ExampleGroup},
    #     which causes us to cut off just before {RSpec::Core::ExampleGroup}
    #     when walking up the ancestor chain.
    #     
    # 3.  Superclass does not respond to `#logger_metadata_named_tags`.
    # 
    if  superclass.nil? ||
        !( superclass < RSpec::Core::ExampleGroup ) ||
        !superclass.respond_to?( :logger_metadata_named_tags )
      {}
    else
      superclass.logger_metadata_named_tags
    end
  end


  # Get logging "named tags" (key/value tag pairs) for the example group's 
  # metadata, specifically for the RSpex hierarchy created by nested 
  # {NRSER::RSpex::ExampleGroup::Describe} method calls.
  # 
  # Used by {#logger_named_tags} and in turn {#logger} to set the logger's
  # {NRSER::Log::Logger#instance_named_tags} when creating them.
  # 
  # Calls {#logger_super_metadata_named_tags} and merges those named tags from
  # the class ancestors with this class' {#logger_description_named_tag}.
  # 
  # @example
  #   require 'nrser/rspex'
  #   
  #   # We're going to write the method response to this variable from inside 
  #   # the inner example group block
  #   description_named_tags = nil
  #   
  #   module M
  #     def self.f; end
  #   end
  #   
  #   MODULE M do
  #     METHOD :f do
  #       # Write the description named tags to the variable we created above.
  #       # 
  #       # In here we are in the `.f` method's example group, which is nested 
  #       # inside the `M` module's example group, so we should get named tags 
  #       # for the `MODULE` and `METHOD`.
  #       description_named_tags = logger_metadata_named_tags
  #     end
  #   end
  #   
  #   # Take a look at the value we captured.
  #   description_named_tags
  #   #=> { "MODULE"=>"M",
  #   #     "INSTANCE_METHOD"=>".f" }
  # 
  # @return [::Hash<String, String>]
  # 
  def logger_metadata_named_tags
    logger_super_metadata_named_tags.merge \
      logger_description_named_tag
  end


  # API method for getting the {NRSER::Log::Logger#instance_named_tags} when
  # creating the {#logger}.
  # 
  # This implementation just calls {#logger_metadata_named_tags}, but is
  # here so classes can easily override it and add/modify the tags just before 
  # logger creation.
  # 
  # @see #logger_metadata_named_tags
  # @see NRSER::Log::Logger#instance_named_tags
  # 
  # @return [::Hash<#to_s, #to_s>]
  #   Must return a {::Hash} whose keys and values will be used as {::String}.
  # 
  def logger_named_tags
    logger_metadata_named_tags
  end


  # The main API method - get the {NRSER::Log::Logger} for this example group 
  # class.
  # 
  # @example
  #   MODULE NRSER::RSpex::ExampleGroup::Logger do
  #     logger.level = :debug
  #     
  #     logger.debug "Here I am!" do {
  #       key_1: "value one",
  #       key_2: "value two",
  #     } end
  #   end
  #   
  #   # Should log something like:
  #   # 
  #   # 2018-10-29 06:50:04.355445 DEBUG RSpec::ExampleGroups
  #   #   MODULE  NRSER::RSpex::ExampleGroup::Logger
  #   # -- Here I am! -- {
  #   #     :key_1 => "value one",
  #   #     :key_2 => "value two"
  #   # }
  # 
  # @return [NRSER::Log::Logger]
  # 
  def logger
    @semantic_logger ||= NRSER::Log[
      'RSpec::ExampleGroups',
      named_tags: logger_named_tags,
    ]
  end

end # module Logger


# /Namespace
# =======================================================================

end # module ExampleGroup
end # module RSpex
end # module NRSER
