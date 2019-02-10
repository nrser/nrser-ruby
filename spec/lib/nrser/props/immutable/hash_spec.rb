# Propertied Immutable Hashes
# ============================================================================
# 
# The {NRSER::Props::Immutable::Hash} module can be mixed into subclasses of
# {Hamster::Hash} (an immutable {Hash}) to provide property encoding,
# decoding and reading backed by the elements of the hash itself.
# 
# This is extremely similar to {NRSER::Props::Immutable::Vector} - which I
# wrote and tested first - so check their for more comments / details.
# 
# Requirements
# ----------------------------------------------------------------------------
# 
# We're going to use the {NRSER::Types} refinements to specify types for our
# props.

require 'nrser/refinements/types'

# And we're going to need the mixin module itself.

require 'nrser/props/immutable/hash'

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

SPEC_FILE(
  spec_path: __FILE__,
  module: NRSER::Props::Immutable::Hash,
) do
  
  SETUP "Simple 2D Integer Point" do
  # ==========================================================================
  
    # Complete Fixture Class
    # --------------------------------------------------------------------------
    # 
    # First, let's look at a working example:
    # 
    
    subject :point_2d_int do
      Class.new( Hamster::Hash ) do
        include NRSER::Props::Immutable::Hash
        
        # So that error messages look right. You don't need this in "regularly"
        # defined classes.
        def self.name; 'Point2DInt'; end
        def self.inspect; name; end
        
        # It's vital that we include the `key:` keyword argument, and that the
        # values are non-negative integer indexes for the vector.
        prop :x, type: t.int
        prop :y, type: t.int
        
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
      
      it { is_expected.to be_a Hamster::Hash }
      
      
      # and it should have the `x` and `y` accessible as hash values via
      # it's `#[]` method:
      
      describe_method :[] do
        describe_called_with :x do
          it { is_expected.to be x }
        end
        
        describe_called_with :y do
          it { is_expected.to be y }
        end
      end # Method [] Description
      
      # as well as via the `#x` and `#y` attribute reader methods that
      # {NRSER::Props} creates:
      
      ATTRIBUTE :x do
        it { is_expected.to be x }
      end
      
      ATTRIBUTE :y do
        it { is_expected.to be y }
      end
      
      # Converting to an array should be equal to `[[:x, x], [:y, y]]`:
      
      ATTRIBUTE :to_a do
        it { is_expected.to include [:x, x], [:y, y] }
      end
      
      # We should get a regular hash out of `#to_h`
      
      ATTRIBUTE :to_h do
        it { is_expected.to eq x: x, y: y }
      end
      
      # We should see our custom `#to_s` value
      
      ATTRIBUTE :to_s do
        it { is_expected.to eq "(#{ x }, #{ y })" }
      end
      
    end
    
    
    SETUP "Creating a Point from `source`" do
    # ========================================================================
      
      # Our subject will be a Point2dInt created from a `source` value that we
      # will define for each example.
      
      subject do
        point_2d_int.new source
      end
      
      
      CASE "From an `{x: Integer, y: Integer}` literal `Hash`" do
      # ------------------------------------------------------------------------
        
        # Let the `source` be the {Hash} `{x: 1, y: 2}`.
        
        WHEN source: {x: 1, y: 2} do
          
          # Now we should be able to construct a point. Test that it behaves
          # like we defined above:
          
          it_behaves_like "Point2DInt", source
          
        end
      end
      
      
      CASE "From a `Hamster::Hash[x: Integer, y: Integer]`" do
      # --------------------------------------------------------------------
      # 
      # All that `#initialize` cares about is that it can access the `source`
      # via `#[]` and that it can tell if it should use names or integer
      # index by looking for `#each_pair` and `#each_index`, respectively.
      # 
        
        WHEN source: Hamster::Hash[x: 1, y: 2] do

          # Now we should be able to construct a point. Test that it behaves
          # like we defined above:
          
          it_behaves_like "Point2DInt", source.to_h
          
        end
      end
      
    end # SETUP "Creating a Point from `source`"
    # ************************************************************************
    
    
    SETUP "Deriving a new point from another" do
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
      
      METHOD :put do
        
        # Change the value at entry 0 to 2
        
        describe_called_with :x, 2 do
          it_behaves_like "Point2DInt", x: 2, y: 2
        end # called with 0, 2
        
        # Type checking should still be in effect, of course
        
        describe_called_with :x, 'hey' do
          it { expect { subject }.to raise_error TypeError }
        end # called with 0, 'hey'
        
      end # Method put Description
      
      
      METHOD :map do
        
        # We have to do some manual funkiness here 'cause
        # `describe_called_with` doesn't take a block...
        # 
        ### TODO
        #   
        #   We should be able to handle this by passing a {NRSER::Message}
        #   to `describe_called_with`, but that's not yet implemented
        #   (RSpex need s a *lot* of work).
        #   
        #       describe_called_with(
        #         NRSER::Message.new { |value| value + 1 }
        #       ) do ...
        #   
        #   or something like that.
        #   
        
        describe "add 1 to each entry" do
          subject do
            super().call { |key, value| [key, value + 1] }
          end
          
          it_behaves_like "Point2DInt", x: 2, y: 3
        end
        
        # Type checking should still be enforced
        
        describe "try to turn entries into Strings" do
          subject do
            super().call { |key, value| [key, "value: #{ value }"] }
          end
          
          it do
            expect { subject }.to raise_error TypeError
          end
        end # "try to turn entries into Strings"
        
      end # Method map Description
      
      
      CASE "Adding extra keys and values" do
      # ======================================================================
      # 
      # At the moment, we *can* add *extra* keys and values to the point.
      # 
      
        # Let's try adding a `:z` key with value `zee`
        
        describe_method :put do
          describe_called_with :z, 'zee' do
            
            # It works! And the new point still behaves as expected.
            
            it_behaves_like "Point2DInt", x: 1, y: 2
            
            # but it *also* has a `:z` key with value `'zee'`, which is not
            # type checked in any way because it has no corresponding prop
            
            it "also has `z: 'zee`" do
              expect( subject[:z] ).to eq 'zee'
            end
            
            ### TODO
            #   
            #   In the future (soon?!), we will have options to configure how
            #   to handle extra values... thinking:
            #   
            #   1.  Allow (what happens now)
            #   2.  Prohibit (raise an error)
            #   3.  Discard (just toss them)
            #   
            #   Of course, we will still discard derived prop values found in
            #   the source so that we can always dump and re-load data values.
            #   
            
          end # called with :z, 3
        end # Method put Description
        
      end # CASE Adding extra keys and values
      # **********************************************************************
      
    end # SETUP Deriving a new point from another
    # ************************************************************************
    
  end # Simple 2D Integer Point
end
