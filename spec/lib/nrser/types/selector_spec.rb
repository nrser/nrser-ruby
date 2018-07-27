require 'nrser/core_ext/symbol'

require 'nrser/refinements/types'
using NRSER::Types


describe_spec_file \
  spec_path: __FILE__,
  module: NRSER::Types,
  method: :selector,
  description: "Using selector types in Enumerable#select" \
do
  
  data = [
    {
      item: "journal",
      qty: 25,
      size: { h: 14, w: 21, uom: "cm" },
      status: "A",
      groups: [ 'a', 'b' ]
    },

    {
      item: "notebook",
      qty: 50,
      size: { h: 8.5, w: 11, uom: "in" },
      status: "A",
      groups: [ 'b', 'c' ],
    },

    {
      item: "paper",
      qty: 100,
      size: { h: 8.5, w: 11, uom: "in" },
      status: "D",
      groups: [ 'a', 'c' ],
    },

    {
      item: "planner",
      qty: 75,
      size: { h: 22.85, w: 30, uom: "cm" },
      status: "D",
      groups: [ 'd', 'e' ],
    },

    {
      item: "postcard",
      qty: 45,
      size: { h: 10, w: 15.25, uom: "cm" },
      status: "A",
      groups: [ 'a' ],
    },
  ]

  subject { data.select( &selector ).map( &[:item] ).to_set }

  use_case "querying for group membership" do

    _when "querying a single group",
          selector: t[ groups: 'b' ] do
      it { is_expected.to \
            eq %w(journal notebook).to_set }; end
  

    # This *works*, but I don't think it's totally what I want...
    _when "querying for members of any of a list of groups",
          selector: \
            t[ groups: ( t.has( 'b' ) | t.has( 'c' ) ) ] do
      it { is_expected.to \
            eq %w(journal notebook paper).to_set }; end


    # Mongo style..? hard to find docs...
    # 
    # https://stackoverflow.com/a/34244908/
    # https://docs.mongodb.com/manual/reference/operator/query/in/#use-the-in-operator-to-match-values-in-an-array
    # 
    # How it seems you would do it there:
    # 
    #     { groups: { $in: [ 'b', 'c', ] } }
    # 
    # but we already used "in" for the opposite thing.
    # so for us how about:
    # 
    #     t[ groups: t.has_any( 'b', 'c' ) ]
    # 
    # Another possible name:
    # 
    #     t[ groups: t.intersects( 'b', 'c' ) ]
    # 
    # Variations:
    # 
    #     t[ groups: t.has_all( 'b', 'c' ) ]
    #     
    # To me right now this reads to me like you're asking if `groups` is "in"
    # [ 'b', 'c' ] - which it's not.
    # 
    #     t[ groups: t.in( 'b', 'c' ) ]
    #
    _when "querying for members of any of a list of groups",
          selector: \
            t[ groups: t.has_any( 'b', 'c' ) ] do
      it { is_expected.to \
            eq %w(journal notebook paper).to_set }; end

  end # USE CASE *************************************************************


  _when selector: t[ status: 'D' ] do
    it { is_expected.to eq %w(paper planner).to_set }; end


  _when selector: t[ item: /^p/ ] do
    it { is_expected.to eq Set[ 'paper', 'planner', 'postcard' ] }; end


  _when "trying out a more complicated selector",
        selector: \
          ( t[ status: 'A' ] | t[ size: t[ w: 11 ] ] ) do
    it { is_expected.to \
          eq Set[ 'notebook', 'paper', 'journal', 'postcard' ] }; end


end # SPEC FILE