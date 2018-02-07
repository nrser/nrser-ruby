require 'nrser/labs/globlin'

describe_spec_file(
  spec_path: __FILE__,
  class: NRSER::Labs::Globlin,
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

    g = NRSER::Globlin.new \
      split: [/[\/\.]/, :words],
      ignore: [:case]

    g.find_only! 'git/repo'

  end
end
