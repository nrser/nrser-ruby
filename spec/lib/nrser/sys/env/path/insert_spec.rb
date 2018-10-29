require 'nrser/sys/env/path'

SPEC_FILE(
  spec_path:        __FILE__,
  class:            NRSER::Sys::Env::Path,
  instance_method:  :insert,
) do
  
  SETUP ~%{
    Create a new instance from `source`, call `#insert` on `args` and compare
    to the string result from `#to_s`
  } do
    
    let( :path ) { NRSER::Sys::Env::Path.new source }
    subject { path.insert( *args ).to_s }
    
    CASE(
      "insert `./test/bin` into PATH before any workdir paths",
      where: {
        args: ['./test/bin', before: %r{^./}],
      }
    ) do
      
      WHEN(
        "`./bin` is the first path in source",
        source: './bin:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert at the start" do
          is_expected.
            to eq "./test/bin:#{ source }"
        end
      end
      
      WHEN(
        "`./bin` is in the middle of the source",
        source: '/some/path:./bin:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert before `./bin`" do
          is_expected.
            to eq '/some/path:./test/bin:./bin:/Users/nrser/bin:/usr/local/bin'
        end
      end
      
      WHEN(
        "`./bin` is at the end of the source",
        source: '/some/path:/Users/nrser/bin:/usr/local/bin:./bin',
      ) do
        it "should insert before `./bin`" do
          is_expected.
            to eq '/some/path:/Users/nrser/bin:/usr/local/bin:./test/bin:./bin'
        end
      end
      
      WHEN(
        "no `./` paths in source",
        source: '/some/path:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert at the end" do
          is_expected.
            to eq '/some/path:/Users/nrser/bin:/usr/local/bin:./test/bin'
        end
      end
    end # insert `./test/bin` into PATH before any workdir paths
    
  end # SETUP
  
end # SPEC_FILE
