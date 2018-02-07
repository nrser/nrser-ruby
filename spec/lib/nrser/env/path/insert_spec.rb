describe_spec_file(
  spec_path:        __FILE__,
  class:            NRSER::Env::Path,
  instance_method:  :insert,
) do
  
  describe_setup %{
    Create a new instance from `source`, call `#insert` on `args` and compare
    to the string result from `#to_s`
  } do
    
    let( :path ) { NRSER::Env::Path.new source }
    subject { path.insert( *args ).to_s }
    
    describe_use_case(
      "insert `./test/bin` into PATH before any workdir paths",
      where: {
        args: ['./test/bin', before: %r{^./}],
      }
    ) do
      
      describe_when(
        "`./bin` is the first path in source",
        source: './bin:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert at the start" do
          is_expected.
            to eq "./test/bin:#{ source }"
        end
      end
      
      describe_when(
        "`./bin` is in the middle of the source",
        source: '/some/path:./bin:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert before `./bin`" do
          is_expected.
            to eq '/some/path:./test/bin:./bin:/Users/nrser/bin:/usr/local/bin'
        end
      end
      
      describe_when(
        "`./bin` is at the end of the source",
        source: '/some/path:/Users/nrser/bin:/usr/local/bin:./bin',
      ) do
        it "should insert before `./bin`" do
          is_expected.
            to eq '/some/path:/Users/nrser/bin:/usr/local/bin:./test/bin:./bin'
        end
      end
      
      describe_when(
        "no `./` paths in source",
        source: '/some/path:/Users/nrser/bin:/usr/local/bin',
      ) do
        it "should insert at the end" do
          is_expected.
            to eq '/some/path:/Users/nrser/bin:/usr/local/bin:./test/bin'
        end
      end
    end # insert `./test/bin` into PATH before any workdir paths
    
  end # setup
  
end # spec
