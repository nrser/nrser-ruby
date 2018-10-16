require 'nrser/refinements/types'
using NRSER::Types


describe NRSER::Types do
  describe 'basic types #test and #check' do
    {
      t.any => {
        pass: [nil, 'blah', 1, 3.14, [], {}, Object.new],
        from_s: {
          pass: ['hey', 'ho', "let's go"],
        },
      },
      
      t.is(1) => {
        pass: [1],
        fail: [2, '1', nil, true],
      },
      
      t.is_a(Array) => {
        pass: [[]],
        fail: [{}],
      },
      
      t.True => {
        pass: [true],
        fail: [1, 'true'],
        from_s: {
          pass: [ 'true', 'True', '1', 'T', 't'],
          fail: [ 'f', '100' ],
        }
      },
      
      t.False => {
        pass: [false],
        fail: [true, 0, nil, 'false'],
        from_s: {
          pass: [ 'false', 'f', 'F', '0' ],
          fail: [ 't', '-1' ],
        }
      },
      
      t.bool => {
        pass: [true, false],
        fail: [0, 1, nil],
      },
      
      t.int => {
        pass: [0, 1, -1, 888],
        fail: ['0', 3.14],
        from_s: {
          pass: ['1', '10', '0', '-1', '1000000000000000000000'],
          fail: ['3.14', '1more', 'hey'],
        }
      },
      
      t.pos_int => {
        pass: [1, 10, 1000000000000000000000],
        fail: [0, -1],
        from_s: {
          pass: ['1', '10', '1000000000000000000000'],
          fail: ['0', '-1', '3.14'],
        }
      },
      
      t.neg_int => {
        pass: [-1, -10, -1000000000000000000000],
        fail: [0, 1],
        from_s: {
          pass: ['-1', '-10', '-1000000000000000000000'],
          fail: ['0', '1', '3.14'],
        }
      },
      
      t.non_neg_int => {
        pass: [0, 1],
        fail: [nil, -1, false],
        from_s: {
          pass: ['0', '1'],
          fail: ['-1'],
        },
      },
      
      t.non_pos_int => {
        pass: [0, -1],
        fail: [1],
        from_s: {
          pass: ['0', '-1'],
          fail: ['1', 'blah'],
        },
      },
      
      t.attrs(to_s: t.str) => {
        pass: [''],
      },
      
      t.bounded(min: 0, max: 0) => {
        pass: [0],
      },
      
      t.union(t.non_neg_int, t.bounded(min: 0, max: 0)) => {
        pass: [0],
      },
      
      t.attrs(length: t.bounded(min: 0, max: 0)) => {
        pass: ['', []],
        fail: ['hey'],
      },
      
      t.array => {
        pass: [[], [1, 2, 3]],
        fail: [nil, {}, '1,2,3'],
        from_s: {
          pass: ['1,2,3', '', '[1,2,3]', 'a, b, c'],
        }
      },
      
      t.array(t.int) => {
        pass: [[], [1, 2, 3]],
        fail: [['1']],
        from_s: {
          pass: ['1,2,3', '', '[1,2,3]'],
          fail: ['a,b,c'],
        }
      },
      
      t.respond_to(:each_value) => {
        pass: [ {} ],
        fail: [ [] ],
      },
      
      t.path => {
        pass: [
          '.',
          Pathname.getwd,
        ],
        
        fail: [
          '',
          123,
        ],
        
        from_s: {
          pass: [
            '.',
          ],
          
          fail: [
            '',
          ],
        },
      }, # t.path
      
    }.each do |type, tests|
      if tests[:pass]
        tests[:pass].each do |value|
          it "ACCEPTS #{ value.inspect } as #{ type }" do
            expect(type.test value).to be true
            expect {type.check value}.not_to raise_error
          end
        end
      end
      
      if tests[:fail]
        tests[:fail].each do |value|
          it "REJECTS #{ value.inspect } as #{ type }" do
            expect(type.test value).to be false
            expect {type.check value}.to raise_error TypeError
          end
        end
      end
      
      if tests[:from_s]
        if tests[:from_s][:pass]
          tests[:from_s][:pass].each do |string|
            unless string.is_a? String
              raise "must be string: #{ string.inspect }"
            end
            
            it "#{ type }#from_s ACCEPTS string #{ string.inspect }" do
              expect{ type.from_s string }.not_to raise_error
            end
          end
        end
      end # from_s
    end # each
  end # basic types #test and #check
  
  describe ".from_repr" do
    {
      t.str => ['string', 'str', 'String', 'STRING', 'STR'],
      t.int => ['int', 'integer', 'Integer', 'INT'],
      t.bool => ['bool', 'boolean', 'Boolean', 'BOOL'],
      t.array => ['array', 'list', 'Array'],
      # t.union('a', 'b', 'c') => [
      #   {
      #     'one_of': ['a', 'b', 'c'],
      #   }
      # ]
    }.each do |type, inputs|
      inputs.each do |input|
        it "converts #{ input.inspect } to #{ type }" do
          expect(NRSER::Types.from_repr input).to eq type
        end
      end
    end
  end # #from_repr
  
end # QB::Types
