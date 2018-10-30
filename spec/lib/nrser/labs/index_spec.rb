require 'nrser/labs/index'

SPEC_FILE(
  spec_path: __FILE__,
  class: NRSER::Labs::Index,
  labs: true, # run with `LABS=1 rspec ...` to include
) do
  it "scratch" do
    
    items = [
      'qb/git/ignore',
      'qb/call',
      'qb/dev/ref/repo/git',
      'qb/dump/vars',
      'qb/facts',
      'qb/git/check/clean',
      'qb/git/repo',
      'qb/github/pages/setup',
      'qb/osx/git/change_case',
      'qb/osx/notif',
      'qb/pkg/bump',
      'qb/project',
      'qb/role',
      'qb/role/qb',
      'qb/rspex/generate',
      'qb/rspex/issue',
      'qb/ruby/bundler',
      'qb/ruby/dependency',
      'qb/ruby/gem/bin_stubs',
      'qb/ruby/gem/build',
      'qb/ruby/gem/install',
      'qb/ruby/gem/new',
      'qb/ruby/gem/release',
      'qb/ruby/rspec/setup',
      'qb/ruby/yard/clean',
      'qb/ruby/yard/config',
      'qb/ruby/yard/setup',
      'qb/yarn/setup',
      'qb.git_submodule_update',
      'qb.hack_npm',
      'qb.install',
      'qb.npm_package',
      'qb.package_json_info',
      'qb.qb_setup',
      'qb.read_json',
      'qb.unhack_gem',
      'qb.yarn_release',
    ]
    
    def split_item item
      item.split( /[\.\/]/ )
    end
    
    expect( split_item 'qb/git/repo' ).to eq ['qb', 'git', 'repo']
    expect( split_item 'qb/git/repo' ).to have_attributes length: 3
    
    # Index one thing
    index = described_class.new( items ) { |item|
      split_item( item ).length
    }
    
    expect( index.key_for 'qb/git/repo' ).to be 3
    
    expect( index.keys ).to include 2, 3, 4, 5
    
    expect( index[3] ).to include 'qb/role/qb'
    
    expect( index[3] ).to eq Set.new items.select { |item|
      split_item( item ).length == 3
    }
    
    expect( true ).to be false
    
    # # Index multiple things
    # names_index = NRSER::Index.new( items ) { |item|
    #   seg = item.split( /\.\// ).length,
    # 
    #   {
    #     seg_count: segs.length,
    #     namespace: segs.first,
    #   }
    # }
    # 
    # names_index[:seg_count]
    
  end
end
