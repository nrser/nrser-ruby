require 'pry'
require 'pathname'
require 'set'

require 'active_support/core_ext/string/inflections'

ENV[ 'NRSER_TEXT_USE_COLOR' ] = 'false'

ROOT = Pathname.new File.expand_path( '..', __dir__ )
LIB_PATH = ROOT.join 'lib'

$yard_doctest_required_filepaths = Set.new

def require_from_filepath filepath
  return if $yard_doctest_required_filepaths.include?( filepath )
  path = /\A(.*)\:\d+\z/.match( filepath )[ 1 ]
  lib_rel = Pathname.new( path ).relative_path_from( LIB_PATH ).to_s
  req_path = lib_rel.sub /\.rb\z/, ''
  require req_path
  $yard_doctest_required_filepaths << filepath
rescue
  log.warn "Unable to require from filepath #{ filepath.inspect }"
end


class ::YARD::Doctest::Example < ::Minitest::Spec
  # @param [::Module | nil] bind
  # 
  def context bind
    @context ||= begin
      if bind
        # NRSER - This is... funky. If we use a regular `#class_eval`, 
        # it's possible for name resolution to work up from *here* first,
        # which is problematic if you happen to been looking for something
        # like {NRSER::Text} *but* there is also an {YARD::NRSER} module
        # loaded, because it will go for {YARD::NRSER::Text}, and fail.
        # 
        # This seems like a ridiculously edge case I've gotten myself into,
        # but I also can't come to any reasons why I *would* be wanting to
        # resolve out of {YARD::Doctest::Example}, and this change makes
        # things a lot nicer and more natural for the {NRSER} gem.
        # 
        # This what was here:
        # 
        #     context = bind.class_eval('binding', __FILE__, __LINE__)
        # 
        # and this is the replacement. By reaching up into the top-level 
        # binding to do our dirty work, we get a binding that resolves 
        # much more like I would expect.
        # 
        # TODO  Could maybe use some clean up work..?
        # 
        context = TOPLEVEL_BINDING.
          eval "#{ bind.name }.class_eval('binding', __FILE__, __LINE__)"
        
        if ENV[ 'YDT_PRY_BIND' ]
          binding.pry
        end
        
        # Oh my god, what is happening here?
        # We need to transplant instance variables from the current binding.
        instance_variables.each do |instance_variable_name|
          local_variable_name = "__yard_doctest__#{instance_variable_name.to_s.delete('@')}"
          context.local_variable_set(local_variable_name, instance_variable_get(instance_variable_name))
          context.eval("#{instance_variable_name} = #{local_variable_name}")
        end
        
        # if bind.name
        #   demod_name = bind.name.demodulize
        #   context.eval "#{ demod_name } = #{ bind.name }"
        # end
        
        context
      else
        binding
      end
    end
  end
end


YARD::Doctest.configure do |doctest|
  doctest.before do |example|
    # this is called before each example and
    # evaluated in the same context as example
    # (i.e. has access to the same instance variables)
    
    require_from_filepath example.filepath
  end

  doctest.after do
    # same as `before`, but runs after each example
  end

  doctest.after_run do
    # runs after all the examples and
    # has different context
    # (i.e. no access to instance variables)
  end
end
