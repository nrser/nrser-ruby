require 'spec_helper'
require 'nrser/refinements'

using NRSER

describe 'Pathname' do
  
  describe '#start_with?' do
    it "works with other Pathname instances" do
      expect(
        Pathname.new('a/b/c').start_with? Pathname.new('a/b')
      ).to be true
      
      expect(
        Pathname.new('a/b/c').start_with? Pathname.new('a/b/')
      ).to be true
      
      expect(
        Pathname.new('/a/b/c').start_with? Pathname.new('/')
      ).to be true
    end
  end # #start_with?
  
  describe '#sub' do
    context "other pathnames" do
      it "works for basic replacement" do
        expect(
          Pathname.new('a/b/c').sub Pathname.new('a/b'), 'c/d'
        ).to eq Pathname.new('c/d/c')
      end
      
      it "only substitutes the first occurrence" do
        expect(
          Pathname.new('c/c/c').sub Pathname.new('c'), 'a'
        ).to eq Pathname.new('a/c/c')
      end
    end
  end
  
end # Pathname
