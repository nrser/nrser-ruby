require 'spec_helper'

require 'nrser/refinements'
using NRSER

describe_method "NRSER.map_tree" do
# ========================================================================
  
  subject { NRSER.method :map_tree }
  
  describe_section "Simple Examples" do
  # ========================================================================
    
    context_where(
      tree: {
        1 => {
          name: 'Mr. Neil',
          fav_color: 'blue',
          age: 33,
          likes: [:tacos, :cats],
        },
        
        2 => {
          name: 'Ms. Mica',
          fav_color: 'red',
          age: 32,
          likes: [:cats, :cookies],
        },
      }
    ) do
      describe "Convert all Integers to Strings" do
        
        subject {
          super().call( tree ) { |element|
            if element.is_a? Integer
              element.to_s
            else
              element
            end
          }
        }
        
        it {
          is_expected.to eq \
            '1' => {
              name: 'Mr. Neil',
              fav_color: 'blue',
              age: '33',
              likes: [:tacos, :cats],
            },
            
            '2' => {
              name: 'Ms. Mica',
              fav_color: 'red',
              age: '32',
              likes: [:cats, :cookies],
            }
        }
        
        
      end # Convert all Integers to Strings
    end # context where

  end # section Simple Examples
  # ************************************************************************
  
  
  describe_section "pruning" do
  # ========================================================================
    
  context_where(
    tree: {
      1 => {
        name: 'Mr. Neil',
        fav_color?: nil,
        age: 33,
        likes: [:tacos, :cats],
      },
      
      2 => {
        name: 'Ms. Mica',
        fav_color?: 'red',
        age: 32,
        likes: [:cats, :cookies],
      },
    }
  ) do
    describe "Convert all Integers to Strings and prune" do
      
      subject {
        super().call( tree, prune: true ) { |element|
          if element.is_a? Integer
            element.to_s
          else
            element
          end
        }
      }
      
      it {
        is_expected.to eq \
          '1' => {
            name: 'Mr. Neil',
            age: '33',
            likes: [:tacos, :cats],
          },
          
          '2' => {
            name: 'Ms. Mica',
            fav_color: 'red',
            age: '32',
            likes: [:cats, :cookies],
          }
      }
      
    end # Convert all Integers to Strings
  end # context where
    
  end # section pruning
  # ************************************************************************
  
  
end # NRSER.map_tree
