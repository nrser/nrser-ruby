# Propertied Immutable Vectors
# ============================================================================
# 
# The {NRSER::Props::Immutable::Vector} module can be mixed into subclasses of
# {Hamster::Vector} (an immutable {Array}) to provide property encoding,
# decoding and reading backed by the elements of the vector itself.
# 
# 
# Requirements
# ----------------------------------------------------------------------------
# 
# We're going to use the {NRSER::Types} refinements to specify types for our
# props.

require 'nrser/refinements/types'

# And we're going to need the mixin module itself.

require 'nrser/props/immutable/vector'

# 
# Refinements
# ----------------------------------------------------------------------------
# 
# Declare that we're going to use the {NRSER::Types} refinements, which just
# provide the global `t` shortcut to {NRSER::Types}.

using NRSER::Types

# 
# Examples
# ----------------------------------------------------------------------------
# 

describe NRSER::Props::Immutable::Vector do

# describe_spec_file(
#   spec_path: __FILE__,
# ) do
  
  # Simple 2D Integer Point
  # ==========================================================================
  # 
  # 
  # Complete Fixture Class
  # --------------------------------------------------------------------------
  # 
  # First, let's look at a working example:
  # 
  
  let :point_2d_int do
    Class.new( Hamster::Vector ) do
      include NRSER::Props::Immutable::Vector
      
      # So that error messages look right. You don't need this in "regularly"
      # defined classes.
      def self.name; 'Point2DInt'; end
      
      # It's vital that we include the `key:` keyword argument, and that the
      # values are non-negative integer indexes for the vector.
      prop :x, type: t.int, key: 0
      prop :y, type: t.int, key: 1
      
      # Just for fun and to show the capabilities, define a `#to_s` to nicely
      # print the point.
      def to_s
        "(#{ x }, #{ y })"
      end
    end
  end
  
  
  describe "Creating a Point" do
  # ------------------------------------------------------------------------
    
    # Our subject will be a Point2dInt created from a `source` value that we
    # will define for each example.
    
    subject do
      point_2d_int.new source
    end
    
    # and let's define our expectations for a point successfully created from
    # a source:
    
    shared_examples "Point2DInt from source" do |x:, y:|
      # It should be an instance of the class
      
      it { is_expected.to be_a point_2d_int }
      
      # and it should have the `x` and `y` accessible as vector entries via
      # it's `#[]` method:
      
      describe_method :[] do
        describe_called_with 0 do
          it { is_expected.to be x }
        end # called with 0
        
        describe_called_with 1 do
          it { is_expected.to be y }
        end # called with 1
      end # Method [] Description
      
      # as well as via the `#x` and `#y` attribute reader methods that
      # {NRSER::Props} creates:
      
      describe_attribute :x do
        it { is_expected.to be x }
      end # Attribute x Description
      
      describe_attribute :y do
        it { is_expected.to be y }
      end # Attribute y Description
      
      # Converting to an array should be equal to `[x, y]`:
      
      describe_attribute :to_a do
        it { is_expected.to eq [x, y] }
      end # Attribute to_a Description
      
    end
    
    describe "From an (x,y) pair Array" do
    # ------------------------------------------------------------------------
      
      # Let the `source` be the {Array} `[1, 2]`.
      # 
      # > **NOTE**
      # >
      # > We do some dumb shit because I don't know how to get RSpec to handle
      # > this property... need `source` to be available in examples so that
      # > `subject` can get it but also to the example group so that we can
      # > use it in `it_behaves_like`..? :/
      # 
      
      def self.source
        [1, 2]
      end
      
      def source
        self.class.source
      end
      
      # Now we should be able to construct a point. Test that it behaves like
      # we defined above:
      
      it_behaves_like "Point2DInt from source", x: source[0], y: source[1]
      
    end
  end
end
