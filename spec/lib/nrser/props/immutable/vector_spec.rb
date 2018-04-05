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

# TODO  Fix this shit!
# 
# describe_spec_file(
#   spec_path: __FILE__,
# ) do
  
  describe "Simple 2D Integer Point" do
  # ==========================================================================
  
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
        prop :x, type: t.int, index: 0
        prop :y, type: t.int, index: 1
        
        # Just for fun and to show the capabilities, define a `#to_s` to nicely
        # print the point.
        def to_s
          "(#{ x }, #{ y })"
        end
      end
    end
    
    # and let's define our expectations for a successfully created point:
    
    shared_examples "Point2DInt" do |x:, y:|
      
      # It should be an instance of the class
      
      it { is_expected.to be_a point_2d_int }
      
      # as well as {Hamster::Vector}!
      
      it { is_expected.to be_a Hamster::Vector }
      
      
      # and it should have the `x` and `y` accessible as vector entries via
      # it's `#[]` method:
      
      describe_method :[] do
        describe_called_with 0 do
          it { is_expected.to be x }
        end
        
        describe_called_with 1 do
          it { is_expected.to be y }
        end
      end # Method [] Description
      
      # as well as via the `#x` and `#y` attribute reader methods that
      # {NRSER::Props} creates:
      
      describe_attribute :x do
        it { is_expected.to be x }
      end
      
      describe_attribute :y do
        it { is_expected.to be y }
      end
      
      # Converting to an array should be equal to `[x, y]`:
      
      describe_attribute :to_a do
        it { is_expected.to eq [x, y] }
      end
      
      # However, {NRSER::Props} *overrides* `#to_h` to provide a {Hash} of
      # the props by name, so that will behave differently
      
      describe_attribute :to_h do
        it { is_expected.to eq x: x, y: y }
      end
      
    end
    
    
    describe_section "Creating a Point" do
    # ========================================================================
      
      # Our subject will be a Point2dInt created from a `source` value that we
      # will define for each example.
      
      subject do
        point_2d_int.new source
      end
      
      # We're going to define these sources at the example group level so that
      # we can use them easily in `it_behaves_like`, but `subject` needs them
      # at the example level, so we provide this little helper:
      
      def source
        self.class.source
      end
      
      
      describe "From an [x, y] pair Array" do
      # ------------------------------------------------------------------------
        
        # Let the `source` be the {Array} `[1, 2]`.
        
        def self.source
          [1, 2]
        end
        
        # Now we should be able to construct a point. Test that it behaves like
        # we defined above:
        
        it_behaves_like "Point2DInt", x: source[0], y: source[1]
        
      end
      
      
      describe "From an {x:, y:} Hash" do
      # ------------------------------------------------------------------------
        
        # Let the `source` be the {Hash} `{x: 1, y: 2}`.
        
        def self.source
          {x: 1, y: 2}
        end
        
        # Now we should be able to construct a point. Test that it behaves like
        # we defined above:
        
        it_behaves_like "Point2DInt", source
        
      end
      
      describe "From a Hamster::Vector[x, y] pair" do
      # ------------------------------------------------------------------------
      # 
      # All that `#initialize` cares about is that it can access the `source`
      # via `#[]` and that it can tell if it should use names or integer
      # index by looking for `#each_pair` and `#each_index`, respectively.
      # 
        
        # Let the `source` be the `Hamster::Vector[1, 2]`.
        
        def self.source
          Hamster::Vector[1, 2]
        end
        
        # Now we should be able to construct a point. Test that it behaves like
        # we defined above:
        
        it_behaves_like "Point2DInt", x: source[0], y: source[1]
        
      end
      
      describe "From a Hamster::Hash[x:, y:]" do
      # ------------------------------------------------------------------------
      # 
      # All that `#initialize` cares about is that it can access the `source`
      # via `#[]` and that it can tell if it should use names or integer
      # index by looking for `#each_pair` and `#each_index`, respectively.
      # 
        
        # Let the `source` be the `Hamster::Hash[x: 1, y: 2]`.
        
        def self.source
          Hamster::Hash[x: 1, y: 2]
        end
        
        # Now we should be able to construct a point. Test that it behaves like
        # we defined above:
        
        it_behaves_like "Point2DInt", source.to_h
        
      end
    end # section Creating a Point
    # ************************************************************************
    
    
    describe_section "Deriving a new point from another" do
    # ========================================================================
    # 
    # Our point instances are immutable, but we can use {Hamster::Vector}'s
    # methods for deriving new instances to derive new points.
    # 
    
      # Let's create a point subject to start off with
      
      subject do
        point_2d_int.new x: 1, y: 2
      end
      
      # and we can play around with a few {Hamster::Vector} methods...
      
      describe_method :put do
        
        # Change the value at entry 0 to 2
        
        describe_called_with 0, 2 do
          it_behaves_like "Point2DInt", x: 2, y: 2
        end # called with 0, 2
        
        # Type checking should still be in effect, of course
        
        describe_called_with 0, 'hey' do
          it { expect { subject }.to raise_error TypeError }
        end # called with 0, 'hey'
        
      end # Method put Description
      
      
      describe_method :map do
        
        # We have to do some manual funkiness here 'cause
        # `describe_called_with` doesn't take a block...
        # 
        # TODO  We should be able to handle this by passing a {NRSER::Message}
        #       to `describe_called_with`, but that's not yet implemented
        #       (RSpex need s a *lot* of work).
        #       
        #           describe_called_with(
        #             NRSER::Message.new { |value| value + 1 }
        #           ) do ...
        #       
        #       or something like that.
        
        describe "add 1 to each entry" do
          subject do
            super().call { |value| value + 1 }
          end
          
          it_behaves_like "Point2DInt", x: 2, y: 3
        end
        
        # Type checking should still be enforced
        
        describe "try to turn entries into Strings" do
          subject do
            super().call { |value| "value: #{ value }" }
          end
          
          it do
            expect { subject }.to raise_error TypeError
          end
        end # "try to turn entries into Strings"
        
      end # Method map Description
      
    end # section Deriving a new point from another
    # ************************************************************************
    
  end # Simple 2D Integer Point
end
