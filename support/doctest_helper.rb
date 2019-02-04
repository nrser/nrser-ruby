require 'pry'
require 'pathname'

ROOT = Pathname.new File.expand_path( '..', __dir__ )
LIB_PATH = ROOT.join 'lib'

def require_source_location source_location
  path = /\A(.*)\:\d+\z/.match( source_location )[ 1 ]
  lib_rel = Pathname.new( path ).relative_path_from( LIB_PATH ).to_s
  req_path = lib_rel.sub /\.rb\z/, ''
  require req_path
rescue
  # raise
end

YARD::Doctest.configure do |doctest|
  doctest.before do |example|
    # this is called before each example and
    # evaluated in the same context as example
    # (i.e. has access to the same instance variables)
    
    require_source_location example.filepath
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
