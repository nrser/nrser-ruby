require 'nrser/core_ext/symbol'

require 'nrser/refinements/types'
using NRSER::Types


describe "Selector" do
  
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
    #
    _when "querying for members of any of a list of groups",
          selector: \
            t[ groups: ( t.has( 'b' ) | t.has( 'c' ) ) ] do
      it { is_expected.to \
            eq %w(journal notebook paper).to_set }; end

  end # USE CASE *************************************************************


  _when selector: t[ status: 'D' ] do
    it { is_expected.to eq %w(paper planner).to_set }; end


  _when selector: t[ item: /^p/ ] do
    it { is_expected.to eq Set[ 'paper', 'planner', 'postcard' ] }; end


  _when "trying out a more complicated selector",
        selector: \
          ( t.Query(status: 'A') | t.Query(size: t.Query(w: 11)) ) do
    it { is_expected.to \
          eq Set[ 'notebook', 'paper', 'journal', 'postcard' ] }; end


end # "Selector"